#!/bin/bash

# Enhanced BGP bucket debugging test
# This will show detailed bucket processing and route grouping

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output_4_bgp"

echo "========================================="
echo "Enhanced BGP Bucket Debugging Test"
echo "========================================="

cd "$OUTPUT_DIR" || exit 1

# Clean up
echo "Cleaning up existing containers..."
docker compose down -v 2>/dev/null

# Start router 147 and 148
echo ""
echo "Starting routers 147 and 148..."
docker compose up -d rnode_147_router0 rnode_148_router0

echo "Waiting 15 seconds for BGP session establishment..."
sleep 15

echo ""
echo "========================================="
echo "Router 147 Logs - Look for bucket debugging:"
echo "========================================="

# Show the last 50 lines with bucket debugging
docker logs as147r-router0-10.147.0.254 2>&1 | grep -E "BGP-RT-NOTIFY|BGP-BUCKET-DEBUG|BGP-gRPC-TX.*Calling bgp_create_update" | tail -50

echo ""
echo "========================================="
echo "Router 147 BGP Status:"
echo "========================================="
docker exec as147r-router0-10.147.0.254 birdc show protocols

echo ""
echo "========================================="
echo "Router 147 Routes:"
echo "========================================="
docker exec as147r-router0-10.147.0.254 birdc show route all

echo ""
echo "========================================="
echo "Router 148 Routes (what it received):"
echo "========================================="
docker exec as148r-router0-10.148.0.254 birdc show route all

echo ""
echo "========================================="
echo "Analysis Summary:"
echo "========================================="
echo "Look for:"
echo "1. How many buckets were created (different bucket addresses)"
echo "2. Which routes went into which buckets"
echo "3. How many times bgp_create_update() was called"
echo "4. Which bucket was processed and sent"
echo "5. Whether local route 10.147.0.0/24 was in a different bucket"

echo ""
echo "To clean up: docker compose down -v"