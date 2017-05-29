$(document).ready(function(){
    var next = 1;
    $(".add-more").click(function(e){
        e.preventDefault();
        var addto = "#field" + next;
        var addRemove = "#field" + (next);
        next = next + 1;
        var newIn = '<div class="input-group field" id="field' + next + '"><input autocomplete="on" class="form-control" id="i' + next + '" name="field' + next + '" type="text" placeholder="Type something" data-items="8"><span class="input-group-btn"><button id="add-more" class="btn btn-default add-more"  type="button">+</button></span></div>';
        var newInput = $(newIn);
        //var removeBtn = '<span class="input-group-btn"><button id="remove' + (next - 1) + '" class="btn btn-default remove-me"  type="button">-</button></span>';
        //var removeButton = $(removeBtn);
        $("#add-more").text('-');
        $("#add-more").attr('class', 'btn btn-default remove-me');
        $("#add-more").attr('id', 'remove-me' + (next - 1));
        $(addto).after(newInput);

        
        //$(addRemove).after(removeButton);
        //$("#field" + next).attr('data-source',$(addto).attr('data-source'));
        $("#count").val(next);  
        
        
            $('.remove-me').click(function(e){
                e.preventDefault();
                var fieldNum = this.id.charAt(this.id.length-1);
                var fieldID = "#field" + fieldNum;
                //$(this).remove();
                $(fieldID).remove();
            });
    });
    

    
});
