#!/bin/bash

# Test the interactive cleanup demo
# This simulates user input to demonstrate the functionality

echo "Testing the interactive cleanup demo..."
echo ""

# Simulate choosing git-filter-repo (option 1) and yes to simulation
echo -e "1\ny" | ./manual_cleanup_demo.sh

echo ""
echo "=================================="
echo "Test completed! The script now includes:"
echo "• Interactive method selection"
echo "• Detailed demonstrations for each tool"
echo "• Simulation capabilities"
echo "• Step-by-step guidance"
