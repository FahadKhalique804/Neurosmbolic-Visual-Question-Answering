class ObjectAssociation:

    def calc_center(self, x, y, w, h):
        """Calculate the center coordinates of a bounding box."""
        cx = x + w / 2
        cy = y + h / 2
        return cx, cy

    # def is_near(self, b1, b2, threshold):
    #     """Check if object b1 is near object b2 based on a distance threshold."""
    #     # Unpack the bounding box values
    #     x1, y1, w1, h1 = b1[1:]  # Bounding box for b1
    #     x2, y2, w2, h2 = b2[1:]  # Bounding box for b2
    #
    #     # Calculate centers of the bounding boxes
    #     cx1, cy1 = self.calc_center(x1, y1, w1, h1)
    #     cx2, cy2 = self.calc_center(x2, y2, w2, h2)
    #
    #     # Calculate Euclidean distance between the centers
    #     distance = math.sqrt((cx2 - cx1) ** 2 + (cy2 - cy1) ** 2)
    #
    #     # Check if the distance is below the threshold
    #     if distance < threshold:
    #         return 'near'
    #     else:
    #         return 'far'

    def is_in(self, b1, b2):
        """Check if object b1 is entirely or partially inside object b2."""
        x1, y1, w1, h1 = b1[1:]  # Object 1 bounding box
        x2, y2, w2, h2 = b2[1:]  # Object 2 bounding box
        return (
                x1 >= x2 and y1 >= y2 and
                x1 + w1 <= x2 + w2 and y1 + h1 <= y2 + h2
        )

    def is_on(self, b1, b2):
        """Check if object b1 is 'on' object b2."""
        x1, y1, w1, h1 = b1[1:]
        x2, y2, w2, h2 = b2[1:]

        # Horizontal overlap check
        if x1 + w1 == x2 or x2 + w2 == x1:
            return True
        # Vertical overlap check
        if y1 + h1 <= y2 or y2 + h2 <= y1:
            return True
        return False

    def is_under(self, b1, b2):
        """Check if object b1 is 'under' object b2."""
        x1, y1, w1, h1 = b1[1:]
        x2, y2, w2, h2 = b2[1:]

        # Check if box1 is directly under box2
        return y1 == y2 + h2 and x1 < x2 + w2 and x1 + w1 > x2

    def is_left(self, b1, b2):
        """Check if object b1 is left of object b2."""
        x1, y1, w1, h1 = b1[1:]
        x2, y2, w2, h2 = b2[1:]
        return x2 > x1 + w1

    def is_right(self, b1, b2):
        """Check if object b1 is right of object b2."""
        x1, y1, w1, h1 = b1[1:]
        x2, y2, w2, h2 = b2[1:]
        return x2 + w2 < x1

    def is_in_front(self, b1, b2):
        """Check if object b1 is in front of object b2."""
        _, y1, _, h1 = b1[1:]
        _, y2, _, h2 = b2[1:]
        return (y1 + h1) < (y2 + h2)

    def is_behind(self, b1, b2):
        """Check if object b1 is behind object b2."""
        _, y1, _, h1 = b1[1:]
        _, y2, _, h2 = b2[1:]
        return (y1 + h1) > (y2 + h2)