#!/bin/bash

# Copy the fixed BIRD source code to each router in output_4_bgp
BIRD_SRC="/home/bashayer/seed-emulator-mbgp/examples/basic/small_mbgp_test/bird"
OUTPUT_DIR="/home/bashayer/seed-emulator-mbgp/examples/basic/small_mbgp_test/output_4_bgp"

echo "Copying fixed BIRD source to router directories..."

for router in rnode_146_router0 rnode_147_router0 rnode_148_router0 rnode_149_router0; do
    if [ -d "$OUTPUT_DIR/$router" ]; then
        echo "Copying to $router..."
        cp -r "$BIRD_SRC" "$OUTPUT_DIR/$router/"
        echo "Done with $router"
    fi
done

echo "All routers updated with fixed BIRD source."