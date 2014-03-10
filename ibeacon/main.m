//
//  main.m
//  scanbeacon
//
//  Created by Christopher Sexton on 3/7/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#import "Scanner.h"
#import "Broadcaster.h"
#import "Macros.h"

static void sigint(const int signum) {
    printf("\n");
    exit(EXIT_SUCCESS);
}

void print_usage() {
    printf("ibeacon: iBeacon command line utility\n");
    printf("\n");
    printf("       -h  --help             Display this message.\n");
    printf("       -s  --scan             Scan for iBeacons.\n");
    printf("       -i  --interval         Time interval in seconds\n");
}

int main(int argc, char * argv[]) {
    int exit_value = EXIT_SUCCESS;

    @autoreleasepool {
        signal(SIGINT, sigint);

        double interval = 1.1;
        boolean_t should_scan = false;
        boolean_t should_broadcast = false;
        NSString *uuid = @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"; // Radius Default
        NSInteger major = 0;
        NSInteger minor = 0;
        NSInteger power = -32;

        static struct option long_options[] =
        {
            {"interval", required_argument, NULL, 'i'},
            {"scan", no_argument, NULL, 's'},
            {"broadcast", no_argument, NULL, 'b'},
            {"major", required_argument, NULL, 'M'},
            {"minor", required_argument, NULL, 'm'},
            {"uuid", required_argument, NULL, 'u'},
            {"power", required_argument, NULL, 'u'},
            {"help", no_argument, NULL, 'h'},
            {NULL, 0, NULL, 0}
        };

        int opt = 0;
        while ((opt = getopt_long(argc, argv, "hsbu:M:m:p:i:", long_options, NULL)) != -1)
        {
            // check to see if a single character or long option came through
            switch (opt)
            {
                case 'i':
                    interval = atof(optarg);
                    break;
                case 's':
                    should_scan = true;
                    break;
                case 'b':
                    should_broadcast = true;
                    break;
                case 'u':
                    uuid = [NSString stringWithUTF8String:optarg];
                    break;
                case 'M':
                    major = atoi(optarg);
                    break;
                case 'm':
                    minor = atoi(optarg);
                    break;
                case 'p':
                    power = atoi(optarg);
                    break;
                case 'h':
                    print_usage();
                    exit(EXIT_SUCCESS);
                    break;
            }
        }

        if (should_scan && should_broadcast) {
            puts("Error: Cannot scan and broadcast at the same time");
            exit(EXIT_FAILURE);
        }
        if (should_scan) {
            Scanner *scanner = [[Scanner alloc] init];
            [scanner startWithTimeInterval:interval];
            [[NSRunLoop currentRunLoop] run];
        }
        if (should_broadcast) {
            Puts(@"Broadcasting iBeacon UUID: %@, Major: %ld, Minor: %ld, Power: %ld", uuid, (long)major, (long)minor, (long)power);
            Broadcaster *broadcaster = [[Broadcaster alloc] init];
            [broadcaster startAdvertisingWithUUID:uuid major:major minor:minor power:power];
            [[NSRunLoop currentRunLoop] run];
        }
    }
    return exit_value;
}

