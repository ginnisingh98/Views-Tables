--------------------------------------------------------
--  DDL for Package Body PN_PAY_GROUP_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_PAY_GROUP_RULES_PKG" AS
  --$Header: PNGRPRLB.pls 115.3 2004/02/12 08:33:15 kkhegde noship $

/*===========================================================================+
 | PROCEDURE insert_row
 | DESCRIPTION
 |    inserts row into pn_pay_group_rules
 | SCOPE - PUBLIC
 | MODIFICATION HISTORY
 |
 | 15-DEC-2003  Kiran  o Created.
 | 03-FEB-2003  Kiran  o Removed ORG_ID from insert_row.
 +===========================================================================*/
PROCEDURE insert_row(
 x_GROUPING_RULE_ID    IN OUT NOCOPY NUMBER
,x_NAME                IN            VARCHAR2
,x_DESCRIPTION         IN            VARCHAR2
,x_LAST_UPDATE_DATE    IN            DATE
,x_LAST_UPDATED_BY     IN            NUMBER
,x_CREATION_DATE       IN            DATE
,x_CREATED_BY          IN            NUMBER
,x_LAST_UPDATE_LOGIN   IN            NUMBER
,x_ATTRIBUTE_CATEGORY  IN            VARCHAR2
,x_ATTRIBUTE1          IN            VARCHAR2
,x_ATTRIBUTE2          IN            VARCHAR2
,x_ATTRIBUTE3          IN            VARCHAR2
,x_ATTRIBUTE4          IN            VARCHAR2
,x_ATTRIBUTE5          IN            VARCHAR2
,x_ATTRIBUTE6          IN            VARCHAR2
,x_ATTRIBUTE7          IN            VARCHAR2
,x_ATTRIBUTE8          IN            VARCHAR2
,x_ATTRIBUTE9          IN            VARCHAR2
,x_ATTRIBUTE10         IN            VARCHAR2
,x_ATTRIBUTE11         IN            VARCHAR2
,x_ATTRIBUTE12         IN            VARCHAR2
,x_ATTRIBUTE13         IN            VARCHAR2
,x_ATTRIBUTE14         IN            VARCHAR2
,x_ATTRIBUTE15         IN            VARCHAR2) IS

CURSOR group_rule IS
  SELECT GROUPING_RULE_ID
  FROM   PN_PAY_GROUP_RULES
  WHERE  GROUPING_RULE_ID = x_GROUPING_RULE_ID;

BEGIN

INSERT INTO PN_PAY_GROUP_RULES
(GROUPING_RULE_ID
,NAME
,DESCRIPTION
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN
,ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15)
VALUES
(NVL(x_GROUPING_RULE_ID, PN_PAY_GROUP_RULES_S.NEXTVAL)
,x_NAME
,x_DESCRIPTION
,x_LAST_UPDATE_DATE
,x_LAST_UPDATED_BY
,x_CREATION_DATE
,x_CREATED_BY
,x_LAST_UPDATE_LOGIN
,x_ATTRIBUTE_CATEGORY
,x_ATTRIBUTE1
,x_ATTRIBUTE2
,x_ATTRIBUTE3
,x_ATTRIBUTE4
,x_ATTRIBUTE5
,x_ATTRIBUTE6
,x_ATTRIBUTE7
,x_ATTRIBUTE8
,x_ATTRIBUTE9
,x_ATTRIBUTE10
,x_ATTRIBUTE11
,x_ATTRIBUTE12
,x_ATTRIBUTE13
,x_ATTRIBUTE14
,x_ATTRIBUTE15)
RETURNING GROUPING_RULE_ID INTO x_GROUPING_RULE_ID;

-- Check if a valid row was inserted
OPEN group_rule;
FETCH group_rule INTO x_GROUPING_RULE_ID;

  IF (group_rule%NOTFOUND) THEN
    CLOSE group_rule;
    RAISE NO_DATA_FOUND;
  END IF;

CLOSE group_rule;

EXCEPTION
  WHEN others THEN
    RAISE;

END insert_row;

/*===========================================================================+
 | PROCEDURE update_row
 | DESCRIPTION
 |    updates a row in pn_pay_group_rules
 | SCOPE - PUBLIC
 | MODIFICATION HISTORY
 |
 |   15-DEC-2003  Kiran  o Created.
 +===========================================================================*/
PROCEDURE update_row(
 x_GROUPING_RULE_ID    IN            NUMBER
,x_NAME                IN            VARCHAR2
,x_DESCRIPTION         IN            VARCHAR2
,x_LAST_UPDATE_DATE    IN            DATE
,x_LAST_UPDATED_BY     IN            NUMBER
,x_LAST_UPDATE_LOGIN   IN            NUMBER
,x_ATTRIBUTE_CATEGORY  IN            VARCHAR2
,x_ATTRIBUTE1          IN            VARCHAR2
,x_ATTRIBUTE2          IN            VARCHAR2
,x_ATTRIBUTE3          IN            VARCHAR2
,x_ATTRIBUTE4          IN            VARCHAR2
,x_ATTRIBUTE5          IN            VARCHAR2
,x_ATTRIBUTE6          IN            VARCHAR2
,x_ATTRIBUTE7          IN            VARCHAR2
,x_ATTRIBUTE8          IN            VARCHAR2
,x_ATTRIBUTE9          IN            VARCHAR2
,x_ATTRIBUTE10         IN            VARCHAR2
,x_ATTRIBUTE11         IN            VARCHAR2
,x_ATTRIBUTE12         IN            VARCHAR2
,x_ATTRIBUTE13         IN            VARCHAR2
,x_ATTRIBUTE14         IN            VARCHAR2
,x_ATTRIBUTE15         IN            VARCHAR2) IS

BEGIN

UPDATE PN_PAY_GROUP_RULES SET
 NAME                = x_NAME
,DESCRIPTION         = x_DESCRIPTION
,LAST_UPDATE_DATE    = x_LAST_UPDATE_DATE
,LAST_UPDATED_BY     = x_LAST_UPDATED_BY
,LAST_UPDATE_LOGIN   = x_LAST_UPDATE_LOGIN
,ATTRIBUTE_CATEGORY  = x_ATTRIBUTE_CATEGORY
,ATTRIBUTE1          = x_ATTRIBUTE1
,ATTRIBUTE2          = x_ATTRIBUTE2
,ATTRIBUTE3          = x_ATTRIBUTE3
,ATTRIBUTE4          = x_ATTRIBUTE4
,ATTRIBUTE5          = x_ATTRIBUTE5
,ATTRIBUTE6          = x_ATTRIBUTE6
,ATTRIBUTE7          = x_ATTRIBUTE7
,ATTRIBUTE8          = x_ATTRIBUTE8
,ATTRIBUTE9          = x_ATTRIBUTE9
,ATTRIBUTE10         = x_ATTRIBUTE10
,ATTRIBUTE11         = x_ATTRIBUTE11
,ATTRIBUTE12         = x_ATTRIBUTE12
,ATTRIBUTE13         = x_ATTRIBUTE13
,ATTRIBUTE14         = x_ATTRIBUTE14
,ATTRIBUTE15         = x_ATTRIBUTE15
WHERE GROUPING_RULE_ID = x_GROUPING_RULE_ID;

IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
END IF;

EXCEPTION
  WHEN others THEN
    RAISE;

END update_row;

/*===========================================================================+
 | PROCEDURE LOCK_ROW_EXCEPTION
 | DESCRIPTION
 |    Gives the statndard message for the offending column in a LOCK_ROW
 |    raised exception
 | SCOPE - PUBLIC
 | ARGUMENTS  : IN: p_column_name, p_new_value
 | RETURNS    : None
 | MODIFICATION HISTORY
 |
 |   15-DEC-2003  Kiran  o Created. Copied from pn_var_rent_pkg.
 +===========================================================================*/
PROCEDURE LOCK_ROW_EXCEPTION (p_column_name in varchar2,
                              p_new_value   in varchar2)
is
BEGIN
PNP_DEBUG_PKG.debug ('PN_PAY_GROUP_RULES_PKG.LOCK_ROW_EXCEPTION (+)');

  fnd_message.set_name ('PN','PN_RECORD_CHANGED');
  fnd_message.set_token ('COLUMN_NAME',p_column_name);
  fnd_message.set_token ('NEW_VALUE',p_new_value);
  app_exception.raise_exception;

PNP_DEBUG_PKG.debug ('PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION (-)');
END lock_row_exception;

/*===========================================================================+
 | PROCEDURE lock_row
 | DESCRIPTION
 |    locks a row in pn_pay_group_rules
 | SCOPE - PUBLIC
 | MODIFICATION HISTORY
 |
 |   15-DEC-2003  Kiran  o Created.
 +===========================================================================*/
PROCEDURE lock_row(
 x_GROUPING_RULE_ID    IN            NUMBER
,x_NAME                IN            VARCHAR2
,x_DESCRIPTION         IN            VARCHAR2
,x_ATTRIBUTE_CATEGORY  IN            VARCHAR2
,x_ATTRIBUTE1          IN            VARCHAR2
,x_ATTRIBUTE2          IN            VARCHAR2
,x_ATTRIBUTE3          IN            VARCHAR2
,x_ATTRIBUTE4          IN            VARCHAR2
,x_ATTRIBUTE5          IN            VARCHAR2
,x_ATTRIBUTE6          IN            VARCHAR2
,x_ATTRIBUTE7          IN            VARCHAR2
,x_ATTRIBUTE8          IN            VARCHAR2
,x_ATTRIBUTE9          IN            VARCHAR2
,x_ATTRIBUTE10         IN            VARCHAR2
,x_ATTRIBUTE11         IN            VARCHAR2
,x_ATTRIBUTE12         IN            VARCHAR2
,x_ATTRIBUTE13         IN            VARCHAR2
,x_ATTRIBUTE14         IN            VARCHAR2
,x_ATTRIBUTE15         IN            VARCHAR2) IS

CURSOR group_rule IS
  SELECT *
  FROM   PN_PAY_GROUP_RULES
  WHERE  GROUPING_RULE_ID = x_GROUPING_RULE_ID
  FOR UPDATE OF GROUPING_RULE_ID NOWAIT;

tlinfo group_rule%ROWTYPE;

BEGIN

OPEN group_rule;
FETCH group_rule INTO tlinfo;

IF group_rule%NOTFOUND THEN
  CLOSE group_rule;
  RETURN;
END IF;

CLOSE group_rule;

IF NOT (tlinfo.GROUPING_RULE_ID = x_GROUPING_RULE_ID) THEN
  lock_row_exception('GROUPING_RULE_ID',tlinfo.GROUPING_RULE_ID);
END IF;

IF NOT (tlinfo.NAME = x_NAME) THEN
  lock_row_exception('NAME',tlinfo.NAME);
END IF;

IF NOT ((tlinfo.DESCRIPTION = x_DESCRIPTION) OR
   (tlinfo.DESCRIPTION IS NULL AND x_DESCRIPTION IS NULL)) THEN
  lock_row_exception('DESCRIPTION',tlinfo.DESCRIPTION);
END IF;

IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = x_ATTRIBUTE_CATEGORY) OR
   (tlinfo.ATTRIBUTE_CATEGORY IS NULL AND x_ATTRIBUTE_CATEGORY IS NULL)) THEN
  lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
END IF;

IF NOT ((tlinfo.ATTRIBUTE1 = x_ATTRIBUTE1) OR
   (tlinfo.ATTRIBUTE1 IS NULL AND x_ATTRIBUTE1 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
END IF;

IF NOT ((tlinfo.ATTRIBUTE2 = x_ATTRIBUTE2) OR
   (tlinfo.ATTRIBUTE2 IS NULL AND x_ATTRIBUTE2 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
END IF;

IF NOT ((tlinfo.ATTRIBUTE3 = x_ATTRIBUTE3) OR
   (tlinfo.ATTRIBUTE3 IS NULL AND x_ATTRIBUTE3 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
END IF;

IF NOT ((tlinfo.ATTRIBUTE4 = x_ATTRIBUTE4) OR
   (tlinfo.ATTRIBUTE4 IS NULL AND x_ATTRIBUTE4 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
END IF;

IF NOT ((tlinfo.ATTRIBUTE5 = x_ATTRIBUTE5) OR
   (tlinfo.ATTRIBUTE5 IS NULL AND x_ATTRIBUTE5 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
END IF;

IF NOT ((tlinfo.ATTRIBUTE6 = x_ATTRIBUTE6) OR
   (tlinfo.ATTRIBUTE6 IS NULL AND x_ATTRIBUTE6 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
END IF;

IF NOT ((tlinfo.ATTRIBUTE7 = x_ATTRIBUTE7) OR
   (tlinfo.ATTRIBUTE7 IS NULL AND x_ATTRIBUTE7 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
END IF;

IF NOT ((tlinfo.ATTRIBUTE8 = x_ATTRIBUTE8) OR
   (tlinfo.ATTRIBUTE8 IS NULL AND x_ATTRIBUTE8 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
END IF;

IF NOT ((tlinfo.ATTRIBUTE9 = x_ATTRIBUTE9) OR
   (tlinfo.ATTRIBUTE9 IS NULL AND x_ATTRIBUTE9 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
END IF;

IF NOT ((tlinfo.ATTRIBUTE10 = x_ATTRIBUTE10) OR
   (tlinfo.ATTRIBUTE10 IS NULL AND x_ATTRIBUTE10 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
END IF;

IF NOT ((tlinfo.ATTRIBUTE11 = x_ATTRIBUTE11) OR
   (tlinfo.ATTRIBUTE11 IS NULL AND x_ATTRIBUTE11 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
END IF;

IF NOT ((tlinfo.ATTRIBUTE12 = x_ATTRIBUTE12) OR
   (tlinfo.ATTRIBUTE12 IS NULL AND x_ATTRIBUTE12 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
END IF;

IF NOT ((tlinfo.ATTRIBUTE13 = x_ATTRIBUTE13) OR
   (tlinfo.ATTRIBUTE13 IS NULL AND x_ATTRIBUTE13 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
END IF;

IF NOT ((tlinfo.ATTRIBUTE14 = x_ATTRIBUTE14) OR
   (tlinfo.ATTRIBUTE14 IS NULL AND x_ATTRIBUTE14 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
END IF;

IF NOT ((tlinfo.ATTRIBUTE15 = x_ATTRIBUTE15) OR
   (tlinfo.ATTRIBUTE15 IS NULL AND x_ATTRIBUTE15 IS NULL)) THEN
  lock_row_exception('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
END IF;

EXCEPTION
  WHEN others THEN
    RAISE;

END lock_row;

/*===========================================================================+
 | PROCEDURE delete_row
 | DESCRIPTION
 |    deletes a row from pn_pay_group_rules
 | SCOPE - PUBLIC
 | MODIFICATION HISTORY
 |
 |   15-DEC-2003  Kiran  o Created.
 +===========================================================================*/
PROCEDURE delete_row(
 x_GROUPING_RULE_ID    IN            NUMBER) IS

BEGIN

DELETE FROM PN_PAY_GROUP_RULES
WHERE GROUPING_RULE_ID = x_GROUPING_RULE_ID;

IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
END IF;

EXCEPTION
  WHEN others THEN
    RAISE;
END delete_row;

END PN_PAY_GROUP_RULES_PKG;

/
