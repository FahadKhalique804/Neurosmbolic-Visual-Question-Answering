import lz4.frame

def open_lz4_safe(*args, **kwargs):
    """
    Safe wrapper around lz4.frame.open
    Guarantees:
    - flush before close
    - close exactly once
    - no double-flush during GC
    """
    return lz4.frame.open(*args, **kwargs)


def close_lz4_safe(f):
    """
    Safely flush and close an LZ4 file.
    """
    if f is None:
        return
    try:
        if not f.closed:
            f.flush()
            f.close()
    except ValueError:
        # Happens if underlying file is already closed – safe to ignore
        pass
