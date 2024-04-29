--------------------------------------------------------
--  DDL for Package Body BOM_RTG_APPLET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_APPLET_PKG" AS
/* $Header: BOMJONWB.pls 120.1 2006/03/02 01:38:03 vhymavat noship $ */

  PROCEDURE Associate_Event(
              x_event_op_seq_id         NUMBER,
              x_operation_type          NUMBER,
              x_new_parent_op_seq_id    NUMBER,
              x_last_updated_by         NUMBER,
              x_last_update_date        DATE,
	      x_return_code    	OUT NOCOPY	VARCHAR,
	      x_error_msg     	OUT NOCOPY	VARCHAR
         ) IS
  BEGIN
    IF (x_operation_type = 2) THEN
    	UPDATE BOM_OPERATION_SEQUENCES
      	SET
           process_op_seq_id	     =     x_new_parent_op_seq_id,
           last_updated_by           =     x_last_updated_by,
           last_update_date          =     NVL(x_last_update_date, SYSDATE)
    	WHERE operation_sequence_id  = x_event_op_seq_id;
    ELSIF (x_operation_type = 3) THEN
    	UPDATE BOM_OPERATION_SEQUENCES
      	SET
           line_op_seq_id            =     x_new_parent_op_seq_id,
           last_updated_by           =     x_last_updated_by,
           last_update_date          =     NVL(x_last_update_date, SYSDATE)
    	WHERE operation_sequence_id  = x_event_op_seq_id;
    END IF;
    IF (SQL%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('BOM','BOM_EVNT_DOES_NOT_EXIST');
     	x_return_code := 'F';
     	x_error_msg := FND_MESSAGE.GET;
    ELSE
	x_return_code := 'S';
	x_error_msg  := '';
    END IF;

  END Associate_Event;

  PROCEDURE Alter_Link(
              x_from_op_seq_id          NUMBER,
              x_to_op_seq_id            NUMBER,
              x_transition_type         NUMBER,
              x_planning_pct            NUMBER,
              x_transaction_type        VARCHAR2,
         --   x_effectivity_date        DATE,
         --   x_disable_date            DATE,
              x_last_updated_by         NUMBER,
              x_creation_date           DATE,
              x_last_update_date        DATE,
              x_created_by              NUMBER,
              x_last_update_login       NUMBER,
              x_attribute_category      VARCHAR2,
              x_attribute1              VARCHAR2,
              x_attribute2              VARCHAR2,
              x_attribute3              VARCHAR2,
              x_attribute4              VARCHAR2,
              x_attribute5              VARCHAR2,
              x_attribute6              VARCHAR2,
              x_attribute7              VARCHAR2,
              x_attribute8              VARCHAR2,
              x_attribute9              VARCHAR2,
              x_attribute10             VARCHAR2,
              x_attribute11             VARCHAR2,
              x_attribute12             VARCHAR2,
              x_attribute13             VARCHAR2,
              x_attribute14             VARCHAR2,
              x_attribute15             VARCHAR2,
              x_return_code   OUT NOCOPY       VARCHAR2,
              x_error_msg     OUT NOCOPY      VARCHAR2
         ) IS

    l_return_code   VARCHAR2(1)   := 'S';
    l_error_msg	    VARCHAR2(2000) := '';

  BEGIN
    IF (x_transaction_type = 'insert') THEN

	-- Call validate and continue if valid
      Validate_Link(
              x_from_op_seq_id  => x_from_op_seq_id,
              x_to_op_seq_id    => x_to_op_seq_id,
              x_transition_type => x_transition_type,
              x_planning_pct    => x_planning_pct,
              x_transaction_type => x_transaction_type,
              x_return_code     => l_return_code,
              x_error_msg       => l_error_msg
        );

      IF (l_return_code = 'S') THEN
	INSERT INTO BOM_OPERATION_NETWORKS(
	      from_op_seq_id,
              to_op_seq_id,
              transition_type,
              planning_pct,
              last_updated_by,
              creation_date,
              last_update_date,
              created_by,
              last_update_login,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
	      ) VALUES (
	      x_from_op_seq_id,
              x_to_op_seq_id,
              x_transition_type,
              x_planning_pct,
              x_last_updated_by,
              NVL(x_creation_date, SYSDATE),
              NVL(x_last_update_date, SYSDATE),
              x_created_by,
              x_last_update_login,
              x_attribute_category,
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15
	      );
      END IF;

    ELSIF (x_transaction_type = 'update') THEN
	-- Call Lock row before updation

	-- Call validate and continue if valid
      Validate_Link(
              x_from_op_seq_id 	=> x_from_op_seq_id,
              x_to_op_seq_id   	=> x_to_op_seq_id,
              x_transition_type => x_transition_type,
              x_planning_pct	=> x_planning_pct,
              x_transaction_type => x_transaction_type,
	      x_return_code	=> l_return_code,
              x_error_msg	=> l_error_msg
	);

      IF (l_return_code = 'S') THEN
      	UPDATE BOM_OPERATION_NETWORKS
    	SET
           transition_type         =       x_transition_type,
           planning_pct            =       x_planning_pct,
           last_update_date        =       NVL(x_last_update_date, SYSDATE),
           last_updated_by         =       x_last_updated_by
    	WHERE from_op_seq_id = x_from_op_seq_id
            and to_op_seq_id = x_to_op_seq_id;
      END IF;

    ELSIF (x_transaction_type = 'delete') THEN
	-- Call Lock row before deletion

	DELETE FROM BOM_OPERATION_NETWORKS
 	WHERE from_op_seq_id = x_from_op_seq_id
            and to_op_seq_id = x_to_op_seq_id;
    END IF;

    IF (SQL%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('BOM','BOM_EVNT_DOES_NOT_EXIST');
	x_return_code := 'F';
    	x_error_msg   := FND_MESSAGE.GET;
    ELSE
	x_return_code := l_return_code;
    	x_error_msg   := l_error_msg;
    END IF;

  END Alter_Link;

  PROCEDURE Validate_Link(
              x_from_op_seq_id     IN   NUMBER,
              x_to_op_seq_id       IN   NUMBER,
              x_transition_type    IN   NUMBER,
              x_planning_pct       IN   NUMBER,
              x_transaction_type   IN	VARCHAR2,
              x_return_code        OUT NOCOPY  VARCHAR2,
              x_error_msg          OUT NOCOPY  VARCHAR2
         ) IS

  dummy 	   	NUMBER;
  primary_exists   	NUMBER := 0;
  link_exists      	NUMBER := 0;
  sum_planning_pct 	NUMBER := 0;
  from_op_seq_num  	NUMBER;
  to_op_seq_num    	NUMBER;
  op_type	   	NUMBER;
  l_from_op_seq_id  	NUMBER;
  l_to_op_seq_id    	NUMBER;
  l_planning_pct	NUMBER := 0;
  l_transition_type	NUMBER;

  BEGIN

   IF (x_transaction_type = 'insert') THEN
    	-- Only one primary
	IF (x_transition_type = 1) THEN
    	SELECT count(*)
    	INTO primary_exists
    	FROM BOM_OPERATION_NETWORKS
    	WHERE from_op_seq_id = x_from_op_seq_id
     		and transition_type = 1;
	END IF;

   	-- Only one link between the same nodes
    	SELECT count(*)
    	INTO link_exists
    	FROM BOM_OPERATION_NETWORKS
    	WHERE from_op_seq_id = x_from_op_seq_id
       		and  to_op_seq_id = x_to_op_seq_id;

    	-- Sum of planning_pct should be <= 100
    	SELECT sum(planning_pct)
    	INTO sum_planning_pct
    	FROM BOM_OPERATION_NETWORKS
    	WHERE from_op_seq_id = x_from_op_seq_id
		AND transition_type IN (1, 2);

   ELSIF (x_transaction_type = 'update') THEN
	BEGIN
	  SELECT from_op_seq_id, to_op_seq_id,
		 transition_type, planning_pct
	  INTO l_from_op_seq_id, l_to_op_seq_id,
		l_transition_type, l_planning_pct
	  FROM BOM_OPERATION_NETWORKS
	  WHERE from_op_seq_id = x_from_op_seq_id
		 and to_op_seq_id = x_to_op_seq_id
		 and transition_type IN (1, 2);
	  EXCEPTION
    	     WHEN NO_DATA_FOUND THEN
		SELECT from_op_seq_id, to_op_seq_id,
			transition_type, planning_pct
          	INTO l_from_op_seq_id, l_to_op_seq_id,
			l_transition_type, l_planning_pct
          	FROM BOM_OPERATION_NETWORKS
          	WHERE from_op_seq_id = x_from_op_seq_id
                 	and to_op_seq_id = x_to_op_seq_id
                 	and transition_type = 3;
	END;
	-- Only one primary
	IF (l_transition_type <> x_transition_type
		and l_transition_type <> 1 and x_transition_type = 1) THEN
        SELECT count(*)
        INTO primary_exists
        FROM BOM_OPERATION_NETWORKS
        WHERE from_op_seq_id = x_from_op_seq_id
        	and to_op_seq_id <> x_to_op_seq_id
        	and transition_type = 1;
	END IF;

	-- Only one link validation NOT reqd for update

	-- Sum of planning_pct should be <= 100
	if l_transition_type <> 3 then
           SELECT sum(planning_pct) - l_planning_pct
           INTO sum_planning_pct
           FROM BOM_OPERATION_NETWORKS
           WHERE from_op_seq_id = x_from_op_seq_id
		AND transition_type IN (1, 2);
	else
	   sum_planning_pct := l_planning_pct;
	end if;

   END IF;

    IF (primary_exists = 1) THEN

	SELECT operation_type, operation_seq_num
	INTO op_type, from_op_seq_num
	FROM bom_operation_sequences
	WHERE operation_sequence_id = x_from_op_seq_id;

	FND_MESSAGE.SET_NAME('BOM','BOM_CHECK_UNIQUE_PRIMARY');
	IF (op_type = 2) THEN
          FND_MESSAGE.SET_TOKEN('OPERATION', 'BOM_PROCESS', TRUE);
        ELSE
          FND_MESSAGE.SET_TOKEN('OPERATION', 'BOM_LINE_OPERATION', TRUE);
        END IF;
        FND_MESSAGE.SET_TOKEN('SEQUENCE_NUMBER',to_char(from_op_seq_num), FALSE);

	x_return_code := 'F';
	x_error_msg   := FND_MESSAGE.GET;

    ELSIF (link_exists = 1) THEN

	SELECT operation_seq_num
        INTO   from_op_seq_num
        FROM   bom_operation_sequences
        WHERE  operation_sequence_id = x_from_op_seq_id;

        SELECT operation_seq_num
        INTO   to_op_seq_num
        FROM   bom_operation_sequences
        WHERE  operation_sequence_id = x_to_op_seq_id;

	FND_MESSAGE.SET_NAME('BOM','BOM_LINK_ALREADY_EXISTS');
      	FND_MESSAGE.SET_TOKEN('FROM_OP_SEQ_ID',to_char(from_op_seq_num), FALSE);
      	FND_MESSAGE.SET_TOKEN('TO_OP_SEQ_ID',to_char(to_op_seq_num), FALSE);
	x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

    ELSIF (x_transition_type <> 3
		and (nvl(sum_planning_pct,0) + x_planning_pct) > 100)
	  OR (x_transition_type = 3 and (nvl(sum_planning_pct,0) > 100)) THEN

	SELECT operation_type, operation_seq_num
        INTO op_type, from_op_seq_num
        FROM bom_operation_sequences
        WHERE operation_sequence_id = x_from_op_seq_id;

        FND_MESSAGE.SET_NAME('BOM','BOM_CHECK_PLANNING_PERCENT');
        IF (op_type = 2) THEN
          FND_MESSAGE.SET_TOKEN('OPERATION', 'BOM_PROCESS', TRUE);
        ELSE
          FND_MESSAGE.SET_TOKEN('OPERATION', 'BOM_LINE_OPERATION', TRUE);
        END IF;
        FND_MESSAGE.SET_TOKEN('SEQUENCE_NUMBER',to_char(from_op_seq_num), FALSE);

        x_return_code := 'F';
        x_error_msg   := FND_MESSAGE.GET;

    ELSE
        x_return_code := 'S';
        x_error_msg   := '';
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('BOM','BOM_EVNT_DOES_NOT_EXIST');
	x_return_code := 'F';
	x_error_msg  := FND_MESSAGE.GET;

  END Validate_Link;

  PROCEDURE Move_Node(
              x_operation_sequence_id   NUMBER,
              x_x_coordinate            NUMBER,
              x_y_coordinate            NUMBER,
              x_last_updated_by         NUMBER,
              x_last_update_date        DATE,
	      x_return_code       OUT NOCOPY   VARCHAR2,
              x_error_msg         OUT NOCOPY  VARCHAR2
         ) IS
  BEGIN
    UPDATE BOM_OPERATION_SEQUENCES
      SET
      	x_coordinate              =     x_x_coordinate,
       	y_coordinate              =     x_y_coordinate,
       	last_updated_by           =     x_last_updated_by,
       	last_update_date          =     NVL(x_last_update_date, SYSDATE)
    WHERE operation_sequence_id   = x_operation_sequence_id;
    IF (SQL%NOTFOUND) THEN
	 FND_MESSAGE.SET_NAME('BOM','BOM_EVNT_DOES_NOT_EXIST');
	x_return_code := 'F';
        x_error_msg := FND_MESSAGE.GET;
    ELSE
        x_return_code := 'S';
        x_error_msg  := '';
    END IF;
  END Move_Node;

END BOM_RTG_APPLET_PKG;

/
