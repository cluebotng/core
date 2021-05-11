ClueBot NG - Core
=================

The core process performs the primary scoring of edits using an artificial neural network.

## Protocol

All request and response packets are based on XML and follow a fixed schema; all fields are expected with relevant values.

### Example Request

```xml
<?xml version="1.0"?>
<WPEditSet>
    <WPEdit>
        <EditType>change</EditType>
        <EditID>1022572696</EditID>
        <comment>/* Political career */</comment>
        <user>JamesVilla44</user>
        <user_edit_count>9146</user_edit_count>
        <user_distinct_pages />
        <user_warns>1</user_warns>
        <prev_user>JamesVilla44</prev_user>
        <user_reg_time>1553976920</user_reg_time>
        <common>
            <page_made_time>1620437208</page_made_time>
            <title>Angelique Foster</title>
            <namespace>Main:</namespace>
            <creator>Moondragon21</creator>
            <num_recent_edits>14</num_recent_edits>
            <num_recent_reversions>0</num_recent_reversions>
        </common>
        <current>
            <minor>false</minor>
            <timestamp>1620720638</timestamp>
            <text>The current contents</text>
        </current>
        <previous>
            <timestamp>1620720514</timestamp>
            <text>The previous contents</text>
        </previous>
    </WPEdit>
</WPEditSet>
```

### Example Response

```xml
<WPEditSet>
    <WPEdit>
        <editid>1022572696</editid>
        <score>0.149043</score>
        <think_vandalism>false</think_vandalism>
    </WPEdit>
</WPEditSet>
```

## Runtime Configuration

There are 2 primary artifacts required for the process to execute;

1. Configuration (`conf/`)
2. Trained data set (`data/`)

Both sets will be compiled as required & included in the generated container/build artifacts.

## Development

To provide a consistent environment, the current build logic is contained within a docker container.

Local complication can be performed via `docker build .`, the CI workflow will also extract the individual binaries for direct consumption.
