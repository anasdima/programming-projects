import java.io.*;
import java.util.*;

public class UserApplication {
	
	
	public static void main(String[] args) {
		
		Modem modem = new Modem(80000);				// Initialize a virtual modem at x bps
		
		int packetLength = 280; // In bits (35*8)
		
		String txMessage=null;
		String rxMessage=null;
		int k=0;
		float rate=0;
		long start=0;
		int count=0;
		
		/* Connect to ithaki */
		System.out.println("Connecting to ithaki...\n");
		
		txMessage="atd2310ithaki\r";			// Setup transmit message to be the dialing of the remote modem
		rxMessage = "";
		try {
		modem.write(txMessage.getBytes());
		
			for(;;) {
				
				if (modem.available()>0) {																		// If there are data to be read in the memory of the virtual modem
					
					k=modem.read();																				// Read the received byte from the remote modem	
					rxMessage+=(char)k;																			// Convert to char, based on ASCII encoding
					
					System.out.print((char)k);
					if(rxMessage.substring(Math.max(0,rxMessage.length() - 4)).contains("\r\n\n\n")) {			// break for if we get \r\n\n\n
						
						System.out.print("userApplication : Got \\r\\n\\n\\n!\n");											
						System.out.print("Connection with ithaki established\n");
						break;
						
					}
				}
			}
		} catch (Exception x) {System.out.print("Caught exception while connecting\n");}
		
		int nBytes=0;
		
		try {
			txMessage="speed\r\n";
			modem.write(txMessage.getBytes());
			for (k=0; k<10; k++) {
				nBytes=0;
				start = System.currentTimeMillis();
			}
				
			while(System.currentTimeMillis() - start < 120000) {
				modem.read();		  
				nBytes++;
			}
         System.out.println(8*nBytes/120);
        } catch (Exception x) {System.out.print("Caught exception while testing speed\n");} 
		
		// /* Interact with ithaki */
		
		System.out.println("Receiving echo packets...\n");
		txMessage = "E5539\r";
		rxMessage = "";	
		long packetTime, packetTimeStart;
		ArrayList<Long> packetTimes = new ArrayList<Long>();
		count=0;
		try {
		
			modem.write(txMessage.getBytes());
			start = System.currentTimeMillis();
			packetTimeStart = System.currentTimeMillis();
			while (System.currentTimeMillis() - start < 240000) {

				if(modem.available() > 0) {
		
					k=modem.read();
					rxMessage+=(char)k;

					if(rxMessage.substring(Math.max(0,rxMessage.length() - 5)).contains("PSTOP")) {
						
						packetTime = System.currentTimeMillis() - packetTimeStart;
						packetTimes.add(packetTime);
						System.out.printf("Received packet: %s | System response: %s\n",rxMessage,String.valueOf(packetTime));
						count++;
						rxMessage="";
						if (count >= 100 && count%100 == 0 ) {
							
							System.out.println(count + " packets read");
						}
						modem.write(txMessage.getBytes());
						packetTimeStart = System.currentTimeMillis();	// Reset the clock
					}
				}
			}
			
			System.out.println(count + " packets read in total");
			
			String path1 = "F:/Workspace/matlab/Diktya I/echoPackets.txt";
			System.out.println("Saving packet times to '" + path1 + "'...");
			
			FileWriter outFile1 = new FileWriter(path1);  
			BufferedWriter outStream1 = new BufferedWriter(outFile1); 

			for(int i=0;i<packetTimes.size();i++) {
				
				outStream1.write(String.valueOf(packetTimes.get(i)));
				outStream1.newLine();
			}
			outStream1.close();
		} catch(Exception x) {System.out.print("Caught exception while interacting\n");}		
		
		System.out.println("Receiving packet bursts...");
		int bursts = 50;
		int packets = 99;
		int delay = 100;
		long burstTimeStart, burstTime;
		ArrayList<Long> throughputs = new ArrayList<Long>();
		count = 0;
		txMessage = " T4697B" + bursts + "P" + packets + "D" + delay + "\r";
		rxMessage = "";
		start = System.currentTimeMillis();
		
		try {
			
			modem.write(txMessage.getBytes());
			start = System.currentTimeMillis();
			burstTimeStart = System.currentTimeMillis();
			while (System.currentTimeMillis() - start < 240000) {
				
				if(modem.available() > 0) {
					
					k=modem.read();
					rxMessage+=(char)k;
					
					if(rxMessage.substring(Math.max(0,rxMessage.length() - 5)).contains("PSTOP")) {
						
						System.out.println(rxMessage);
						count++;
						rxMessage="";

						if (count >= packets && count%packets == 0 ) {
							
							burstTime = System.currentTimeMillis() - burstTimeStart;
							throughputs.add((packetLength*packets/burstTime)*1000);
							System.out.println(count + " packets read");
							burstTimeStart = System.currentTimeMillis();	// Reset the clock
						}
						if (count >= bursts * packets && count%(bursts*packets) == 0) {		// If number of packets read is multiple of bursts*packets then bursts have ended
							
							System.out.println("Bursts ended. Requesting new ones...");
							modem.write(txMessage.getBytes());
							
						}						
					}
				}
			}
		
			System.out.println(count + " packets read in total");
			
			String path2 = "F:/Workspace/matlab/Diktya I/throughputs.txt";
			System.out.print("Saving throughputs to '" + path2 + "'...");
			
			FileWriter outFile2 = new FileWriter(path2);  
			BufferedWriter outStream2 = new BufferedWriter(outFile2); 
	
			for(int i=0;i<throughputs.size();i++) {
				
				outStream2.write(String.valueOf(throughputs.get(i)));
				outStream2.newLine();
			}
			outStream2.close();
			System.out.println("done!");
		
		} catch(Exception x) {System.out.print("Caught exception while interacting\n");}
		
		System.out.println("Receiving error free image...");
		txMessage = "M7594\r";
		rxMessage = "";
		String imgPath1 = "F:/Workspace/matlab/Diktya I/img_error_free.jpeg";
		count=0;
		start = System.currentTimeMillis();
		try {
				
			modem.write(txMessage.getBytes());
				
			FileOutputStream out1 = new FileOutputStream(imgPath1);
			while (System.currentTimeMillis() - start < 120000) {

				if(modem.available() > 0) {
					k=modem.read();
					rxMessage += (char)k;
					out1.write(k);

				}
			}
			
			out1.close();
			
		} catch(Exception x) {System.out.print("Caught exception while interacting\n");}
		System.out.println("Image saved to: " + imgPath1);
		
		System.out.println("Receiving image with errors...");
		txMessage = "G0780\r";
		rxMessage = "";
		String imgPath2 = "F:/Workspace/matlab/Diktya I/img_errors.jpeg";
		count=0;
		start = System.currentTimeMillis();
		try {
				
			modem.write(txMessage.getBytes());
				
			FileOutputStream out2 = new FileOutputStream(imgPath2);
			while (System.currentTimeMillis() - start < 120000) {

				if(modem.available() > 0) {
					k=modem.read();
					rxMessage += (char)k;
					out2.write(k);

				}
			}
			
			out2.close();
			
		} catch(Exception x) {System.out.print("Caught exception while interacting\n");}
		System.out.println("Image saved to: " + imgPath2);
					
		System.out.println("Starting ARQ mechanism");
		txMessage = "Q2935\r";
		rxMessage = "";
		count=0;
		int xorResult=0, fcsInt=0;
		int tempChar,nextChar,NACKCounter=0;
		long ACKTime, ACKTimeStart;
		ArrayList<Long> ACKTimes = new ArrayList<Long>();
		ArrayList<Integer> NACKS = new ArrayList<Integer>();
		String FCS="";
		
		try {
			
			modem.write(txMessage.getBytes());
			start = System.currentTimeMillis();
			ACKTimeStart = System.currentTimeMillis();
		
			while (System.currentTimeMillis() - start < 240000) {
				
				if(modem.available() > 0) {
					
					k=modem.read();
					rxMessage+=(char)k;

					if(rxMessage.substring(Math.max(0,rxMessage.length() - 5)).contains("PSTOP")) {
						
						System.out.println("Server send: " + rxMessage);
						
						/* Packet validity check */ 
						
						System.out.println("Checking packet...");
						
						tempChar = rxMessage.charAt(31); // First char of 16-char encrypted sequence
						
						for(int i=32;i<47;i++) {
							
							nextChar = (int)rxMessage.charAt(i);
							xorResult = tempChar ^ nextChar;
							tempChar = xorResult;	// xorResult up to now is stored in tempChar
							
						}
						
						FCS = rxMessage.substring(50,52);
						
						fcsInt = Integer.parseInt(FCS); // Convert FCS to int
						
						if(xorResult == fcsInt) {
													
							ACKTime = System.currentTimeMillis() - ACKTimeStart;
							ACKTimes.add(ACKTime);
							if(!(NACKCounter == 0)) {
								NACKS.add(NACKCounter);
							}
							NACKCounter = 0;
							
							txMessage = "Q2935\r";
							System.out.println("ACK");
							ACKTimeStart = System.currentTimeMillis();
						}
						else {	
							
							NACKCounter++;
							
							txMessage = "R5782\r";
							System.out.println("Packet had errors, sending NACK...");
							
						}
						
						modem.write(txMessage.getBytes());
						
						count++;
						if (count >= 100 && count%100 == 0 ) {
							
							System.out.println(count + " packets read");
						}
						
						rxMessage="";
						FCS="";
						
					}
				}
			}
			
			System.out.println(count + " packets read");
			
			String path3 = "F:/Workspace/matlab/Diktya I/ACKTimes.txt";
			System.out.print("Saving ACKTimes to '" + path3 + "'...");
			
			FileWriter outFile3 = new FileWriter(path3);  
			BufferedWriter outStream3 = new BufferedWriter(outFile3); 
	
			for(int i=0;i<ACKTimes.size();i++) {
				
				outStream3.write(String.valueOf(ACKTimes.get(i)));
				outStream3.newLine();
			}
			outStream3.close();
			System.out.println("done!");
			
			String path4 = "F:/Workspace/matlab/Diktya I/NACKS.txt";
			System.out.print("Saving NACK counts to '" + path4 + "'...");
			
			FileWriter outFile4 = new FileWriter(path4);  
			BufferedWriter outStream4 = new BufferedWriter(outFile4); 
	
			for(int i=0;i<NACKS.size();i++) {
				
				outStream4.write(String.valueOf(NACKS.get(i)));
				outStream4.newLine();
			}
			outStream4.close();
			System.out.println("done!");
			
			
			
		} catch(Exception x) {System.out.print("Caught exception while interacting\n");}
	}
}
