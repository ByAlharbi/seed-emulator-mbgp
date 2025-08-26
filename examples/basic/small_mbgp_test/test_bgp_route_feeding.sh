#!/bin/bash

# Test script for BGP route feeding issue
# Tests the 3-router scenario: 146 ↔ 147 ↔ 148

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output_4_bgp"

echo "========================================="
echo "BGP Route Feeding Test"
echo "Testing scenario: Router 146 ↔ 147 ↔ 148"
echo "========================================="

# Navigate to output directory
cd "$OUTPUT_DIR" || exit 1

# Clean up any existing containers
echo "Cleaning up existing containers..."
docker compose down -v 2>/dev/null

# Start routers 146 and 147 first
echo ""
echo "Step 1: Starting routers 146 and 147..."
docker compose up -d rnode_146_router0 rnode_147_router0

# Wait for BGP sessions to establish
echo "Waiting 10 seconds for BGP sessions to establish between 146 and 147..."
sleep 10

# Check BGP status on router 147
echo ""
echo "Checking BGP status on router 147:"
docker exec as147r-router0-10.147.0.254 birdc show protocols

# Start router 148
echo ""
echo "Step 2: Starting router 148..."
docker compose up -d rnode_148_router0

# Wait for BGP session to establish
echo "Waiting 10 seconds for BGP session to establish with 148..."
sleep 10

# Check BGP status on all routers
echo ""
echo "========================================="
echo "Final BGP Status Check:"
echo "========================================="

echo ""
echo "Router 146 BGP status:"
docker exec as146r-router0-10.146.0.254 birdc show protocols

echo ""
echo "Router 147 BGP status:"
docker exec as147r-router0-10.147.0.254 birdc show protocols

echo ""
echo "Router 148 BGP status:"
docker exec as148r-router0-10.148.0.254 birdc show protocols

# Check routes on router 148
echo ""
echo "========================================="
echo "Routes on Router 148 (should see both 10.146.0.0/24 AND 10.147.0.0/24):"
echo "========================================="
docker exec as148r-router0-10.148.0.254 birdc show route

# Check for any assertion failures in router 148 logs
echo ""
echo "========================================="
echo "Checking Router 148 logs for assertion failures:"
echo "========================================="
docker logs as148r-router0-10.148.0.254 2>&1 | grep -i "assertion\|error" | tail -20

# Test bidirectional routing
echo ""
echo "========================================="
echo "Routes on Router 147 (should see 10.148.0.0/24 from 148):"
echo "========================================="
docker exec as147r-router0-10.147.0.254 birdc show route

echo ""
echo "========================================="
echo "Test complete. Summary:"
echo "========================================="
echo "1. Check if router 148 received both routes (10.146.0.0/24 and 10.147.0.0/24)"
echo "2. Check if there are no assertion failures in router 148"
echo "3. Check if bidirectional routing works (147 receives 10.148.0.0/24)"

echo ""
echo "To clean up, run: docker compose down -v"