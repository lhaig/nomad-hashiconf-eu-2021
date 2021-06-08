name = "web-qa-quota"
description = "Limit the tpi-region web-qa namespace"

# Create a limit for the global region. Additional limits may
# be specified in-order to limit other regions.
limit {
    region = "tpi-region"
    region_limit {
        cpu = 2500
        memory = 1000
    }
}