import java.net.*;
import java.io.*;
import java.util.*;
import javax.sound.sampled.*;
public class userApplication {
	public static void main(String[] args) {
		// TCP
		byte[] addressArray = { (byte)155,(byte)207,(byte)18,(byte)208 };
		int portNumber = 80;
		String message="";
		try {
			InetAddress inetAddress = InetAddress.getByAddress(addressArray);
			Socket s = new Socket(inetAddress, portNumber);
			InputStream in = s.getInputStream();
			OutputStream out = s.getOutputStream();
			out.write("GET /index.html HTTP/1.0\r\n\r\n".getBytes());
			long timeStart = System.currentTimeMillis();
			while (System.currentTimeMillis() - timeStart < 1000) {
				char a = (char)in.read();
				message += a;
			}
			String path = "F:/Workspace/http_reply.txt";
			FileWriter outFile = new FileWriter(path);
			outFile.write(message);
			outFile.close();
		} catch (Exception x) {System.out.println(x);}
		// UDP

		String echoResponsePath = "F:/Workspace/echoResponse.txt";
		String echoThroughputsPath = "F:/Workspace/echoThroughputs.txt";
		String imageCAM1Path = "F:/Workspace/imageCAM1.jpeg";
		String waveFormGenPath = "F:/Workspace/waveFormGen.txt";
		String waveFormRepoPath = "F:/Workspace/waveFormRepo.txt";
		String meanPath = "F:/Workspace/means.txt";
		String stepPath = "F:/Workspace/steps.txt";
		String dpcmDiffsPath = "F:/Workspace/dpcmDiffs.txt";
		String dpcmSamplesPath = "F:/Workspace/dpcmSamples.txt";
		String aqdpcmDiffsPath = "F:/Workspace/aqdpcmDiffs.txt";
		String aqdpcmSamplesPath = "F:/Workspace/aqdpcmSamples.txt";
		byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };
		int clientPort = 48006;
		int serverPort = 38006;
		int runTime = 0;
		long timeStart = 0;

		try {
			InetAddress hostAddress = InetAddress.getByAddress(hostIP);
			String packetInfo = "";
			byte[] txbuffer = new byte[50];
			byte[] rxbuffer = new byte[2048];
			DatagramSocket s = new DatagramSocket();
			DatagramPacket p = new DatagramPacket(txbuffer,txbuffer.length, hostAddress,serverPort);
			DatagramSocket r = new DatagramSocket(clientPort);
			DatagramPacket q = new DatagramPacket(rxbuffer,rxbuffer.length);
			r.setSoTimeout(6000);
			//Echo packets//
			packetInfo = "E0000";
			txbuffer = packetInfo.getBytes();
			p.setData(txbuffer);
			p.setLength(txbuffer.length);
			runTime = 240000;
			int runningSecond = 0;
			ArrayList<Long> packetTimes = new ArrayList<Long>();
			long[] bps = new long[runTime/1000];
			long packetTime, packetTimeStart;
			s.send(p);
			packetTimeStart = System.currentTimeMillis();
			timeStart = System.currentTimeMillis();

			while (System.currentTimeMillis() - timeStart < runTime) {
				r.receive(q);
				runningSecond = (int) (System.currentTimeMillis() - timeStart)/1000;
				packetTime = System.currentTimeMillis() - packetTimeStart;
				if (runningSecond == bps.length) {
					bps[runningSecond-1]+=32;
				}
				else {
					bps[runningSecond]+=32;
				}
				packetTimes.add(packetTime);
				packetTimeStart = System.currentTimeMillis();
				s.send(p);
			}
			FileWriter outFile1 = new FileWriter(echoResponsePath);
			BufferedWriter outStream1 = new BufferedWriter(outFile1);
			System.out.println("Saving packet times to '" + echoResponsePath + "'...");
			for(int i=0;i<packetTimes.size();i++) {
				outStream1.write(String.valueOf(packetTimes.get(i)));
				outStream1.newLine();
			}
			outStream1.close();
			System.out.println("Saving throughputs to '" + echoThroughputsPath + "'...");
			FileWriter outFile2 = new FileWriter(echoThroughputsPath);
			BufferedWriter outStream2 = new BufferedWriter(outFile2);
			int j = 0;
			int range = 8;
			long throughput = 0;
			while (j+range < bps.length) {
			//Moving average
				for(int i=j;i<=j+range;i++) {
				throughput += bps[i];
			}
				throughput = throughput/range;
				outStream2.write(String.valueOf(throughput));
				outStream2.newLine();
				throughput = 0;
				j++;
			}
			outStream2.close();
			//Images//
			FileOutputStream imageCAM1OutStream = new FileOutputStream(imageCAM1Path);
			packetInfo = "M7332CAM=PTZ";
			txbuffer = packetInfo.getBytes();
			p.setData(txbuffer);
			p.setLength(txbuffer.length);
			s.send(p);
			timeStart = System.currentTimeMillis();
			runTime = 120000;
			while (System.currentTimeMillis()-timeStart <= 120000) {
				r.receive(q);
				for(int i=0;i<q.getLength();i++) {
					imageCAM1OutStream.write(rxbuffer[i]);
				}
			}
			imageCAM1OutStream.close();
			//Audio//
			int count = 0, audioPacketsN = 10*32, audioPacketSize = 128, AQHeaderSize = 4, Q;
			int D1 = 0, D2 = 0, step = 0, step_low = 0, step_high = 0, mean = 0, mean_low = 0, mean_high = 0, l = 0;
			byte[] audioPackets = new byte[audioPacketsN*audioPacketSize];
			byte[] audioBuffer;
			int[] AQParameters = new int[audioPacketsN*2];
			int[] samples = new int[audioPacketSize*audioPacketsN*2];
			FileWriter dpcmWriter,aqdpcmWriter,meanWriter,stepWriter;
			BufferedWriter dpcmOutStream,aqdpcmOutStream,stepOutStream;
			String AQ = "";
			String source = "F";
			j = 0;
			if (audioPacketsN <= 99) {
				if (source == "T") {
					packetInfo = "V7533" + source + "0" + audioPacketsN;
				}
				else {
					packetInfo = "V7533L00" + AQ + source + "0" + audioPacketsN;
				}
			}
			else {
				if (source == "T") {
					packetInfo = "V7533" + source + audioPacketsN;
				}
				else {
					packetInfo = "V7533L32" + AQ + source + audioPacketsN;
				}
			}
			txbuffer = packetInfo.getBytes();
			if (AQ == "AQ") {
				rxbuffer = new byte[audioPacketSize+AQHeaderSize];
				audioBuffer = new byte[audioPacketsN*audioPacketSize*4];
				Q = 16;
			}
			else {
				rxbuffer = new byte[audioPacketSize];
				audioBuffer = new byte[audioPacketsN*audioPacketSize*2];
				Q = 8;
			}
			AudioFormat PCMFormat = new AudioFormat(8000,Q,1,true,false);
			SourceDataLine player = AudioSystem.getSourceDataLine(PCMFormat);
			p.setData(txbuffer);
			p.setLength(txbuffer.length);
			q.setData(rxbuffer);
			q.setLength(rxbuffer.length);
			s.send(p);
			if (AQ == "AQ") {
					aqdpcmWriter = new FileWriter(stepPath);
					aqdpcmOutStream = new BufferedWriter(aqdpcmWriter);
				while (count < audioPacketsN) {
					r.receive(q);
					//AQ-DPCM Parameters
					mean_low = (int) rxbuffer[0];
					mean_high = (int) rxbuffer[1];
					mean_high = mean_high << 8;
					mean = (mean_low & 0xff) | mean_high;
					step_low = (int) rxbuffer[2];
					step_high = (int) rxbuffer[3];
					step_high = step_high << 8;
					step = (step_low & 0xff) | step_high;
					//AQ-DPCM Decoding
					for (int i=4;i<audioPacketSize+AQHeaderSize;i++) {
						D1 = (((rxbuffer[i] & 0xf0) >> 4)-8);
						D2 = ((rxbuffer[i] & 0xf) -8);
						aqdpcmOutStream.write(String.valueOf(D1));
						aqdpcmOutStream.newLine();
						aqdpcmOutStream.write(String.valueOf(D2));
						aqdpcmOutStream.newLine();
						if(j == 0 || (j % 256) == 0) {
							samples[j] = D1*step;
							samples[j+1] = D2*step + samples[j];
						}
						else {
							samples[j] = samples[j-1] + D1*step;
							samples[j+1] = samples[j] + D2*step;
						}
						j+=2;
					}
					for(int i=l;i<l+audioPacketSize*2;i++) {
						samples[i] += mean;
					}
					l += audioPacketSize*2;
					count++;
				}
			}
			else {
				while (count < audioPacketsN) {
					r.receive(q);
					for (int i=0;i<audioPacketSize;i++) {
						audioPackets[i + count*audioPacketSize] = rxbuffer[i];
					}
					count++;
				}
			}
			if (AQ == "AQ") {
				aqdpcmWriter = new FileWriter(aqdpcmSamplesPath);
				aqdpcmOutStream = new BufferedWriter(aqdpcmWriter);
				j=0;
				for(int i=0;i<samples.length;i++) {
					audioBuffer[j] = (byte) (samples[i]);
					audioBuffer[j+1] = (byte) (samples[i] >> 8);
					aqdpcmOutStream.write(String.valueOf(samples[i]));
					aqdpcmOutStream.newLine();
					aqdpcmOutStream.write(String.valueOf(samples[i] >> 8));
					aqdpcmOutStream.newLine();
					j+=2;
				}
			}
			else {
				dpcmWriter = new FileWriter(dpcmDiffsPath);
				dpcmOutStream = new BufferedWriter(dpcmWriter);
				for (int i=0;i<audioPackets.length;i++) {
					D1 = (((audioPackets[i] & 0b11110000) >> 4) -8);
					D2 = ((audioPackets[i] & 0b00001111) -8);
					dpcmOutStream.write(String.valueOf(D1));
					dpcmOutStream.newLine();
					dpcmOutStream.write(String.valueOf(D2));
					dpcmOutStream.newLine();
					if(j == 0 || (j % 256) == 0) {
						samples[j] = D1;
						samples[j+1] = D2 + samples[j];
					}
					else {
						samples[j] = D1 + samples[j-1];
						samples[j+1] = D2 + samples[j];
					}
					j+=2;
				}
				if (source == "T") {
					dpcmWriter = new FileWriter(waveFormGenPath);
				}
				else {
					dpcmWriter = new FileWriter(waveFormRepoPath);
				}
				dpcmOutStream = new BufferedWriter(dpcmWriter);
				for (int i=0;i<samples.length;i++) {
					audioBuffer[i] = (byte) samples[i];
					dpcmOutStream.write(String.valueOf(samples[i]));
					dpcmOutStream.newLine();
				}
			}
			System.out.println("Playing...");
			player.open(PCMFormat, audioBuffer.length);
			player.start();
			player.write(audioBuffer,0,audioBuffer.length);
			for(;;) {
			}
		} catch (Exception x) {System.out.println(x);}
	}
}
