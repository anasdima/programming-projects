# encoding: UTF-8
require 'tiny_tds'

client = TinyTds::Client.new username: 'Main\Tasos', password: 'password', host: 'localhost', database: 'HMMYStat'

start_time = Time.now
result = client.execute("SELECT Id,Semester FROM Students")
students = result.each
result.cancel
students.each do |s|
	#generate a random student class since these are non existing students
	student_class = rand(1..2)
	#find which core courses the student has taken
	sql = "SELECT S.Id, S.Splitted
	FROM Subjects S, Students St
	WHERE St.Semester >= S.Semester
	AND S.Semester <= 5
	AND St.Id = #{s["Id"]}"
	result = client.execute(sql)
	student_core_courses = result.each
	result.cancel
	#randomize for each of those core courses "which ones he passed"
	passed_subjects = {}
	student_core_courses.each do |scc|
		subject_id = scc["Id"].to_i
		random_chance = rand(0.0..1.0) #random chance that the student passed the subject. Different for each student and each subject
		if s["Semester"] <= 5 
			if usually_zero(random_chance) == 0 # a core cycle student has a mediocre chance to pass a core course
				passed_subjects[subject_id] = 1
			else
				passed_subjects[subject_id] = 0
			end
		elsif s["Semester"] > 5 and s["Semester"] <= 10
			if usually_zero(random_chance + 0.1) == 0 # a specialization cycle student has decent chance to pass a core course
				passed_subjects[subject_id] = 1
			else
				passed_subjects[subject_id] = 0
			end
		elsif s["Semester"] > 10
			if usually_zero(random_chance + 0.15) == 0 # an over normal period student has a good chance to pass a core course
				passed_subjects[subject_id] = 1
			else
				passed_subjects[subject_id] = 0
			end
		end
	end
	#randomize the grades and the exam he passed it (or didn't pass it)
	i = 0
	passed_subjects.each do |subject_id,passed|

		puts "Student: #{s["Id"]} Subject: #{subject_id} Passed: #{passed}"

		#find the exams the subject was examed
		if student_core_courses[i]["Splitted"] == true
			if student_class == 1
				sql = "SELECT SE.Teachings_Id, E.Period
				FROM SubjectExams SE, Teachings T, Subjects S, Exams E
				WHERE S.Id = #{subject_id}
				AND T.Subject_Id = S.Id
				AND SE.Teachings_Id = T.Id
				AND E.Id = SE.Exams_Id
				AND T.Class = N'Α-Χ'"
			else
				sql = "SELECT SE.Teachings_Id, E.Period
				FROM SubjectExams SE, Teachings T, Subjects S, Exams E
				WHERE S.Id = #{subject_id}
				AND T.Subject_Id = S.Id
				AND SE.Teachings_Id = T.Id
				AND E.Id = SE.Exams_Id
				AND T.Class = N'Χ-Ω'"
			end
		else
			sql = "SELECT SE.Teachings_Id, E.Period
			FROM SubjectExams SE, Teachings T, Subjects S, Exams E
			WHERE S.Id = #{subject_id}
			AND T.Subject_Id = S.Id
			AND SE.Teachings_Id = T.Id
			AND E.Id = SE.Exams_Id
			AND T.Class = N'Α-Ω'"
		end
		result = client.execute(sql)
		subject_exams = result.each

		exams = []
		subject_exams.each do |se|
			exams << se["Period"]
		end
		teachings = []
		subject_exams.each do |se|
			teachings << se["Teachings_Id"]
		end

		number_of_exams = exams.length

		#Generate random grades and number of failed attempts
		
		#How many tries did it take?
		number_of_tries = rand(1..rand(3..4))
		
		#Which exams did the tries happen?
		last_try = 0
		tries = Array.new(number_of_tries) {|a| a={"Period" => nil, "Teachings_Id" => nil, "Grade" => nil}}
		for k in 1..number_of_tries do
			upper_limit = number_of_exams-(number_of_tries-k) #make sure that the first try doesnt happen in 2014 while the last exam is in 2014 and relevant senarios
			random_index = rand(last_try...upper_limit)
			random_grade = nil
			if k == number_of_tries
				if passed == 1 #if this is the successful try
					random_grade = rand(5..10)
				else
					random_grade = rand(1..4)
				end
			else
				random_grade = rand(1..4)
			end
			tries[k-1]["Period"] = exams[random_index]
			tries[k-1]["Teachings_Id"] = teachings[random_index]
			tries[k-1]["Grade"] = random_grade
			last_try = random_index + 1
		end
		i += 1

		# insert the generated student grades into the database
		tries.each do |try|
			sql = "INSERT INTO Grades (Student_Id,Teachings_Id,Period,Grade)
			VALUES (#{s["Id"]}, #{try["Teachings_Id"]}, N'#{try["Period"]}', #{try["Grade"]})"
			result = client.execute(sql)
			result.cancel
		end
	end
end