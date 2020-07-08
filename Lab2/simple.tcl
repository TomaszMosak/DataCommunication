#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
$ns color 4 Purple

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Open the Trace file
set tf [open out.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail
$ns duplex-link $n4 $n0 2Mb 10ms DropTail
$ns duplex-link $n4 $n1 2Mb 10ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n2 $n3 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n4 $n0 orient right-up
$ns duplex-link-op $n4 $n1 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5


#Setup a TCP connection
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#Setup a TCP2 connection
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n4 $tcp2
set sink [new Agent/TCPSink]
$ns attach-agent $n0 $sink
$ns connect $tcp2 $sink
$tcp2 set fid_ 4

#Setup a FTP2 over TCP2 connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

#Setup a UDP2 connection
set udp2 [new Agent/UDP]
$ns attach-agent $n3 $udp2
set null [new Agent/Null]
$ns attach-agent $n4 $null
$ns connect $udp2 $null
$udp2 set fid_ 3

#Setup a CBR2 over UDP2 connection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false


#Schedule events for the CBR and FTP agents
$ns at 0.5 "$ftp2 start"
$ns at 0.8 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 1.5 "$cbr stop"
$ns at 2.3 "$cbr start"
$ns at 3.0 "$cbr2 start"
$ns at 4.0 "$cbr2 stop"
$ns at 4.5 "$cbr2 start"
$ns at 5.0 "$ftp2 stop"
$ns at 6.0 "$cbr2 stop"
$ns at 7.2 "$cbr stop"
$ns at 7.5 "$cbr2 start"
$ns at 8.0 "$ftp stop"
$ns at 9.0 "$cbr2 stop"

#Detach tcp and sink agents (not really necessary)
$ns at 8.2 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"
$ns at 8.2 "$ns detach-agent $n4 $tcp2 ; $ns detach-agent $n0 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 10.00 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"
puts "CBR packet size = [$cbr2 set packet_size_]"
puts "CBR interval = [$cbr2 set interval_]"

#Run the simulation
$ns run
