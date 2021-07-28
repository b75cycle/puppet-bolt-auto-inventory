#!/bin/bash
bolt command run "diag dvm device list" --targets ip_of_fmg --no-host-key-check  --user fmguser >  fortigates.txt

