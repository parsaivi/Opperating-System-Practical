#!/bin/bash
# Test script for memtest in xv6

cd /home/divar/Documents/OS/6_n/Opperating-System-Practical/xv6-riscv

# Start QEMU with a timeout and send commands
timeout 60s make qemu CPUS=1 > test_output.txt 2>&1 <<'EOF' &
memtest
halt
EOF

QEMU_PID=$!

# Wait for QEMU to complete or timeout
wait $QEMU_PID

# Display the output
echo "===== Test Output ====="
cat test_output.txt

# Clean up
rm -f test_output.txt
