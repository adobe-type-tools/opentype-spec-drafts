A basic design for supporting variable composites with an Item Variation Store:

First, it's very likely that the most common difference in variation model
(among axis values and transformation parameters) will be that some values will
be variable while others won't. So I'm addressing that specifically with a
bitmap, inserted after the `gid` field.

Let F be the number of flags set between bit 3 and bit 11 inclusive on this
Variable Component entry. Add field `varMap[(F+numAxes+7)/8]` after `gid` typed
as `uint8` with notes "Bitmap of which values are variable."

(Note: this mechanism might also make sense for a TVS-based system.)

Second, we implicitly assign a unique index, in increasing order starting from
0, to each value in Variable Component array for which the corresponding varMap
bit is set.

The remaining third task is to associate each index with a major and minor
number in the IVS. We do this with the following system:

Starting major number (resets for new glyph): 0
Starting minor number (resets for new glyph): 0

1 byte operators:

00000000: Pick a new persistent major number with the next argument
11111111: Pick a temporary major number with the next argument

000?????: Increment the current minor number for the next ?????? entries.
001?????: Pick a new temporary minor number with the next argument and increment it for the next ?????? entries.
010?????: Pick a new persistent minor number with the next argument and increment it for the next ?????? entries.
011?????: Reserved
10??????: Multiply ?????? by the next uint8 argument and increment the current minor number for that number of entries.  
11??????: Pick a new persistent minor number with the next argument, multiply ?????? by the following uint8_t argument and increment the current major number for that number of entries. (Excludes 11111111)

Argument sizes:

Major number: Enough bytes to pick among Item Variation Data subtables (i.e. 1
if itemVariationDataCount <= 255, 2 if 255 < itemVariationDataCount < 65536, and so on).

Minor number: Enough bytes to pick among the delta sets of the current Item Variation Data 
subtable (i.e. 1 if itemCount <= 255, 2 if 255 < itemCount < 65536, and so on).

Scope of temporary major number: The next minor number operator
Scope of temporary minor number: The temporary minor number operator

Constraints: 

The number of entries specified for a glyph must be exactly the number varMap
bits set among the variable component entries in the array for that glyph.

Examples:

Major number 0 for all entries, minor number starting at 516 (out of less than 
2^16) for 212 entries

Operator    Major  Minor   Mult
0b11100000         0x0204  0x06  (Pick new persistent minor number 516 and use it for 32 * 6 entries)
0b00010100                       (Increment current minor number 708 for next 20 entries)


Do the same up to entry 101, which uses major number 4 (out of less than 255)
and minor number 28, then continue:

Operator    Major  Minor   Mult
0b11000010         0x0204  0x02  (Pick new persistent minor number 516 and use it for 50 * 2 entries)
0b11111111  0x04                 (New temporary major number 4)
0b00100001         0x001C        (Use new minor number 28 for one entry)
                                 (Major number back to 0, minor number back to 616)
0x10000010                 0x32  (Increment the current minor number for 2 * 50 entries)
0x00001011                       (Increment the current minor number for 11 entries)

entryCount = (total number of varMap bits set)
majorNumber = 0
minorNumber = 0
tmpMajorNumber = None
tmpMinorNumber = None
curEntry = 0
while curEntry < entryCount:
    instr = read(1)
    if instr =~ 0b0000000:
        tmpMajorNumber = read(bytesfor(itemVariationDataCount))
        continue
    else if instr =~ 0b11111111:
        majorNumber = read(bytesfor(itemVariationDataCount))
        continue

    if tmpMajorNumber is not None:
        thisMajorNumber = tmpMajorNumber
    else
        thisMajorNumber = majorNumber

    if instr =~ 0b000?????:
        count = ?????
    else if instr =~ 0b001?????:
        count = ?????
        tmpMinorNumber = read(bytesfor(itemCount of ivd at itemVariationDataOffsets[thisMajorNumber]))
    else if instr =~ 0b010?????:
        count = ?????
        minorNumber = read(bytesfor(itemCount of ivd at itemVariationDataOffsets[thisMajorNumber]))
    else if instr =~ 0b10??????:
        count = ?????? * read(1)
    else if instr =~ 0b11??????:
        count = ??????
        minorNumber = read(bytesfor(itemCount of ivd at itemVariationDataOffsets[thisMajorNumber]))
        count *= read(1)

    if tmpMinorNumber is not None:
        thisMinorNumber = tmpMinorNumber
    else:
        thisMinorNumber = minorNumber

    for i in range(count):
        itemMap[curEntry++] = (thisMajorNumber, thisMinorNumber++)

    if tmpMajorNumber is not None:
        tmpMajorNumber = None

    if tmpMinorNumber is not None:
        tmpMinorNumber = None
    else
        minorNumber += count
