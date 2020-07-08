# Simulation with AODV Routing Protocol
# Def‌ine Options
# By Dr. Idris Skloul Ibrahim

set val(chan)	Channel/WirelessChannel		;	# Channel Type
set val(prop)	Propagation/TwoRayGround	;	# Radio-Propagation Model
set val(netif)	Phy/WirelessPhy			    ;	# Network Interface Type
set val(mac)	Mac/802_11			        ;	# MAC Type
set val(ifq)	Queue/DropTail/PriQueue		;	# Interface Queue Type
set val(ll)		LL				            ;	# Link Layer Type
set val(ant)	Antenna/OmniAntenna		    ;	# Antenna Model
set val(ifqlen)	50							;	# Maximum Packets in IFQ
set val(nn)		4							;	# Number of Mobile Nodes
set val(rp)		AODV						;	# Routing Protocol
set val(initialenergy)	100					; 	# Initial Energy of node
set val(lm)		"off"						;	# log movement
set val(x)		500							;	# X Dimension of Topography
set val(y)		500							;	# Y Dimension of Topography
set val(stop)	30							; 	# Time of Simulation end


set ns_	[new Simulator]				
set tracefd  [open $val(rp)_trace_file_4_nodes.tr w]
set namtrace [open simple_out.nam w]

$ns_ use-newtrace				;	#For using new trace formats

$ns_ trace-all $tracefd

$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

Agent/AODV set num_nodes $val(nn)

# Setting up Topography Object

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

# Create nn mobilenodes [$val(nn)] and attach them to channel

set chan_1_ [new $val(chan)]

# Configure the nodes

$ns_ node-config 	-adhocRouting $val(rp) \
			-llType $val(ll) \
			-macType $val(mac) \
			-channel $chan_1_ \
			-ifqType $val(ifq) \
			-ifqLen $val(ifqlen) \
			-antType $val(ant) \
			-propType $val(prop) \
			-phyType $val(netif) \
			-topoInstance $topo \
			-agentTrace ON \
			-routerTrace ON \
			-macTrace ON \
			-movementTrace OFF \

for {set i 0} {$i < $val(nn)} {incr i} {
set node_($i) [$ns_ node]
}

# Provide Initial Location of Mobile Nodes

$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
#$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
#$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
#$node_(2) set Z_ 0.0

$node_(3) set X_ 290.0
$node_(3) set Y_ 330.0
#$node_(3) set Z_ 0.0



# Generation of Movements

$ns_ at 1.0 "$node_(0) setdest 250.0 350.0 30.0"
#$ns_ at 1.5 "$node_(1) setdest 45.0 285.0 5.0"
#$ns_ at 2.0 "$node_(2) setdest 480.0 300.0 5.0"
#$ns_ at 3.0 "$node_(3) setdest 50.0 80.0 5.0"


# Set a TCP connection between node_(0) and node_(1)

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 1.0 "$ftp start"

#set tcp [new Agent/TCP/Newreno]
#$tcp set class_ 2
#set sink [new Agent/TCPSink]
#$ns_ attach-agent $node_(2) $tcp
#$ns_ attach-agent $node_(3) $sink
#$ns_ connect $tcp $sink
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#$ns_ at 3.0 "$ftp start"

# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {
# 30 defines the node size for nam
$ns_ initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends

for {set i 0} {$i < $val(nn)} { incr i} {
$ns_ at $val(stop) "$node_($i) reset"
}

# Ending nam and the simulation
#$ns_ at 9.0 "$ftp stop"
$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
$ns_ at $val(stop) "stop"

# This method of calling print-stats should not be used as it should be called everytime with a node's id 
# However it shall do the same work
# $ns_ at 100.00 "[$node_(1) agent 255] print-stats"
$ns_ at 30.01 "puts \" Simulation will end soon" 
$ns_ at 30.01 "puts \" End of simulation\" ; $ns_ halt"

proc stop {} {
global ns_ tracefd namtrace
$ns_ flush-trace
close $tracefd
close $namtrace
#Agent/AODV print-stats
exec nam simple_out.nam &
exit 0
}

$ns_ run
