--------------------------------------------------------
--  DDL for Package Body PN_VAR_RENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_RENT_PKG" AS
/* $Header: PNVRFUNB.pls 120.44.12010000.2 2008/09/04 12:27:24 mumohan ship $ */

/*===========================================================================+
--  NAME         : INSERT_PERIODS_ROW
--  DESCRIPTION  : Create recORds IN the PN_VAR_PERIODS table based on
--                 VALUES IN PN_VAR_RENT_DATES
--  PURPOSE      :
--  INVOKED FROM :
-- ARGUMENTS     : IN:
--                    X_ROWID
--                    X_PERIOD_ID
--                    X_PERIOD_NUM
--                    X_VAR_RENT_ID
--                    X_START_DATE
--                    X_END_DATE
--
--                 OUT:
--                    X_ROWID
--                    X_PERIOD_ID
--                    X_PERIOD_NUM
--  REFERENCE    : PN_COMMON.debug()
--  NOTES        : Create recORds IN the PN_VAR_PERIODS table bASed on VALUES IN
--                 PN_VAR_RENT_DATESurrently beINg used IN view
--                 "PN_PAYMENT_SCHEDULES_V"
--  HISTORY      :
--
-- 31-AUG-01  DThota   o Created
-- 20-JUN-02  DThota   o Added ORg_id FOR multi-ORg changes
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_PERIODS with _ALL table.
-- 26-OCT-05  piagrawa o Bug#4702709 - Passed org id in insert row handler.
-- 01-DEC-05  pikhar   o Fetched org_id using cursor
+===========================================================================*/
PROCEDURE INSERT_PERIODS_ROW
(X_ROWID              IN OUT NOCOPY VARCHAR2,
 X_PERIOD_ID          IN OUT NOCOPY NUMBER,
 X_PERIOD_NUM         IN OUT NOCOPY NUMBER,
 X_VAR_RENT_ID        IN NUMBER,
 X_START_DATE         IN DATE,
 X_END_DATE           IN DATE,
 X_PRORATION_FACTOR   IN NUMBER,
 X_PARTIAL_PERIOD     IN VARCHAR2,
 X_ATTRIBUTE_CATEGORY IN VARCHAR2,
 X_ATTRIBUTE1         IN VARCHAR2,
 X_ATTRIBUTE2         IN VARCHAR2,
 X_ATTRIBUTE3         IN VARCHAR2,
 X_ATTRIBUTE4         IN VARCHAR2,
 X_ATTRIBUTE5         IN VARCHAR2,
 X_ATTRIBUTE6         IN VARCHAR2,
 X_ATTRIBUTE7         IN VARCHAR2,
 X_ATTRIBUTE8         IN VARCHAR2,
 X_ATTRIBUTE9         IN VARCHAR2,
 X_ATTRIBUTE10        IN VARCHAR2,
 X_ATTRIBUTE11        IN VARCHAR2,
 X_ATTRIBUTE12        IN VARCHAR2,
 X_ATTRIBUTE13        IN VARCHAR2,
 X_ATTRIBUTE14        IN VARCHAR2,
 X_ATTRIBUTE15        IN VARCHAR2,
 X_CREATION_DATE      IN DATE,
 X_CREATED_BY         IN NUMBER,
 X_LAST_UPDATE_DATE   IN DATE,
 X_LAST_UPDATED_BY    IN NUMBER,
 X_LAST_UPDATE_LOGIN  IN NUMBER,
 X_ORG_ID                NUMBER
) IS

   CURSOR C IS
      SELECT ROWID
      FROM PN_VAR_PERIODS_ALL
      WHERE PERIOD_ID = X_PERIOD_ID;

   CURSOR org_id_cur IS
      SELECT org_id
      FROM   PN_VAR_RENTS_ALL
      WHERE  VAR_RENT_ID =  X_VAR_RENT_ID;

   l_org_id NUMBER;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_PERIODS_ROW (+)');

   -------------------------------------------------------
   -- We need to generate the period number
   -------------------------------------------------------
   SELECT  NVL(MAX(pnp.PERIOD_NUM),0)
   INTO    X_PERIOD_NUM
   FROM    PN_VAR_PERIODS_ALL      pnp
   WHERE   pnp.VAR_RENT_ID    =  X_VAR_RENT_ID;

   X_PERIOD_NUM    := X_PERIOD_NUM + 1;

   -------------------------------------------------------
   -- SELECT the nextval FOR period id
   -------------------------------------------------------
   IF ( X_PERIOD_ID IS NULL) THEN
           SELECT  pn_var_periods_s.nextval
           INTO    X_PERIOD_ID
           FROM    dual;
   END IF;

   IF X_ORG_ID IS NULL THEN
      FOR org_id_rec IN org_id_cur LOOP
         l_org_id := org_id_rec.org_id;
      END LOOP;
   ELSE
      l_org_id := X_ORG_ID;
   END IF;

   INSERT INTO PN_VAR_PERIODS_ALL
   (
      PERIOD_ID,
      PERIOD_NUM,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      VAR_RENT_ID,
      START_DATE,
      END_DATE,
      PRORATION_FACTOR,
      PARTIAL_PERIOD,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ORG_ID
   )
   VALUES
   (
      X_PERIOD_ID,
      X_PERIOD_NUM,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_VAR_RENT_ID,
      X_START_DATE,
      X_END_DATE,
      X_PRORATION_FACTOR,
      X_PARTIAL_PERIOD,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      l_org_id
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%NOTFOUND) THEN
     CLOSE c;
     RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_PERIODS_ROW (-)');

END INSERT_PERIODS_ROW;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_PERIODS_ROW
 |
 | DESCRIPTION
 |    DELETE recORds FROM the PN_VAR_PERIODS
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : DELETE recORds FROM the PN_VAR_PERIODS table
 |
 | MODIFICATION HISTORY
 |
 |     03-SEP-2001  Daniel Thota  o Created
 |     27-DEC-2001  Daniel Thota  o INcluded parameter x_term_date
 |     14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_PERIODS with _ALL table.
 +===========================================================================*/
PROCEDURE DELETE_PERIODS_ROW (
  X_VAR_RENT_ID IN NUMBER,
  X_TERM_DATE   IN DATE
) IS

   l_date DATE;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_PERIODS_ROW (+)');

   l_date := NVL(x_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

   DELETE FROM PN_VAR_PERIODS_ALL
   WHERE VAR_RENT_ID = X_VAR_RENT_ID
   AND   START_DATE  > l_date
   AND   END_DATE    > l_date;

   /* IN cASe OF a no data found FOR a given date */
   IF x_term_date IS NULL THEN
      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END IF;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_PERIODS_ROW (-)');

END DELETE_PERIODS_ROW;



/*===========================================================================+
 | PROCEDURE
 |    CREATE_REPORT_DATES
 |
 | DESCRIPTION
 |    Inserts the records into PN_VAR_REPORT_DATES_ALL
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Inserts the records into PN_VAR_REPORT_DATES_ALL
 |
 | MODIFICATION HISTORY
 |
 |  10-JAN-2006  Prabhakar o Created.
 +===========================================================================*/
PROCEDURE CREATE_REPORT_DATES (p_var_rent_id IN NUMBER) IS

CURSOR get_group_details  IS
SELECT GRP_DATE_ID,
       GRP_START_DATE,
       GRP_END_DATE,
       ORG_ID
FROM pn_var_grp_dates_all
WHERE var_rent_id = p_var_rent_id;


CURSOR get_dates_frequency  IS
SELECT decode(vrg_reptg_freq_code,   'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     null)  report_frequency,
       decode(reptg_freq_code,       'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     null)  group_frequency
FROM pn_var_rent_dates_all
WHERE var_rent_id = p_var_rent_id;


p_creation_date       DATE    := SYSDATE;
p_created_by          NUMBER  := NVL (fnd_profile.VALUE ('USER_ID'), 0);
l_group_frequency     NUMBER  := NULL;
l_report_frequency    NUMBER  := NULL;
l_report_date_id      NUMBER  := NULL;
l_row_id              VARCHAR2(18) := NULL;
l_group_date_id       NUMBER  := NULL;
l_group_start_date    DATE    := NULL;
l_group_end_date      DATE    := NULL;
l_report_start_date   DATE    := NULL;
l_report_end_date     DATE    := NULL;
l_org_id              NUMBER  := NULL;


BEGIN

FOR rec1 IN get_dates_frequency LOOP
   l_group_frequency := rec1.group_frequency;
   l_report_frequency := rec1.report_frequency;
END LOOP;

FOR rec2 IN get_group_details LOOP

    l_group_date_id := rec2.grp_date_id;
    l_group_start_date := rec2.grp_start_date;
    l_group_end_date := rec2.grp_end_date;
    l_org_id := rec2.org_id;

    WHILE l_group_start_date <= l_group_end_date LOOP

       l_report_start_date := l_group_start_date;
       l_report_end_date := least(l_group_end_date,
                                  add_months(l_report_start_date,l_report_frequency)-1);
       l_row_id := NULL;
       l_report_date_id := NULL;
       PN_VAR_RENT_PKG.INSERT_REPORT_DATE_ROW
                              (
                  X_ROWID                =>     l_row_id
                 ,X_REPORT_DATE_ID       =>     l_report_date_id
                 ,X_GRP_DATE_ID          =>     l_group_date_id
                 ,X_VAR_RENT_ID          =>     p_var_rent_id
                 ,X_REPORT_START_DATE    =>     l_report_start_date
                 ,X_REPORT_END_DATE      =>     l_report_end_date
                 ,X_CREATION_DATE        =>     p_creation_date
                 ,X_CREATED_BY           =>     p_created_by
                 ,X_LAST_UPDATE_DATE     =>     p_creation_date
                 ,X_LAST_UPDATED_BY      =>     p_created_by
                 ,X_LAST_UPDATE_LOGIN    =>     p_created_by
                 ,X_ATTRIBUTE_CATEGORY   =>     NULL
                 ,X_ATTRIBUTE1           =>     NULL
                 ,X_ATTRIBUTE2           =>     NULL
                 ,X_ATTRIBUTE3           =>     NULL
                 ,X_ATTRIBUTE4           =>     NULL
                 ,X_ATTRIBUTE5           =>     NULL
                 ,X_ATTRIBUTE6           =>     NULL
                 ,X_ATTRIBUTE7           =>     NULL
                 ,X_ATTRIBUTE8           =>     NULL
                 ,X_ATTRIBUTE9           =>     NULL
                 ,X_ATTRIBUTE10          =>     NULL
                 ,X_ATTRIBUTE11          =>     NULL
                 ,X_ATTRIBUTE12          =>     NULL
                 ,X_ATTRIBUTE13          =>     NULL
                 ,X_ATTRIBUTE14          =>     NULL
                 ,X_ATTRIBUTE15          =>     NULL
                 ,X_ORG_ID               =>     l_org_id
                             );
            l_group_start_date := l_report_end_date + 1;
    END LOOP;
END LOOP;

END CREATE_REPORT_DATES;

/*============================================================================+
--  NAME         : INSERT_REPORT_DATE_ROW
--  DESCRIPTION  : create records in the pn_var_report_dates table based on
--                 values in pn_var_grp_dates_all
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS     : IN:
--                    X_ROWID
--                    X_REOPRT_DATE_ID
--                    X_GRP_DATE_ID
--                    x_VAR_RENT_ID
--                    X_REPORT_START_DATE
--                    X_REPORT_END_DATE
--                    X_CREATION_DATE
--                    X_CREATED_BY
--                    X_LAST_UPDATE_DATE
--                    X_LAST_UPDATED_BY
--                    X_LAST_UPDATE_LOGIN
--                    X_ORG_ID
--                    X_ATTRIBUTE_CATEGORY
--                    X_ATTRIBUTE1
--                    X_ATTRIBUTE2
--                    X_ATTRIBUTE3
--                    X_ATTRIBUTE4
--                    X_ATTRIBUTE5
--                    X_ATTRIBUTE6
--                    X_ATTRIBUTE7
--                    X_ATTRIBUTE8
--                    X_ATTRIBUTE9
--                    X_ATTRIBUTE10
--                    X_ATTRIBUTE11
--                    X_ATTRIBUTE12
--                    X_ATTRIBUTE13
--                    X_ATTRIBUTE14
--                    X_ATTRIBUTE15
--                 OUT:
--                    X_ROWID
--                    X_REPORT_DATE_ID
--
--  REFERENCE    : PN_COMMON.debug()
--  NOTES        : create records in the pn_var_report_dates table based on values
--                 in pn_var_grp_dates_all
--  HISTORY      :
--
--  09-JAN-2006  Prabhakar o Created.
+=============================================================================*/
PROCEDURE INSERT_REPORT_DATE_ROW
(
   X_ROWID               IN OUT NOCOPY VARCHAR2,
   X_REPORT_DATE_ID      IN OUT NOCOPY NUMBER,
   X_GRP_DATE_ID         IN NUMBER,
   X_VAR_RENT_ID         IN NUMBER,
   X_REPORT_START_DATE   IN DATE,
   X_REPORT_END_DATE     IN DATE,
   X_CREATION_DATE       IN DATE,
   X_CREATED_BY          IN NUMBER,
   X_LAST_UPDATE_DATE    IN DATE,
   X_LAST_UPDATED_BY     IN NUMBER,
   X_LAST_UPDATE_LOGIN   IN NUMBER,
   X_ATTRIBUTE_CATEGORY  IN VARCHAR2,
   X_ATTRIBUTE1          IN VARCHAR2,
   X_ATTRIBUTE2          IN VARCHAR2,
   X_ATTRIBUTE3          IN VARCHAR2,
   X_ATTRIBUTE4          IN VARCHAR2,
   X_ATTRIBUTE5          IN VARCHAR2,
   X_ATTRIBUTE6          IN VARCHAR2,
   X_ATTRIBUTE7          IN VARCHAR2,
   X_ATTRIBUTE8          IN VARCHAR2,
   X_ATTRIBUTE9          IN VARCHAR2,
   X_ATTRIBUTE10         IN VARCHAR2,
   X_ATTRIBUTE11         IN VARCHAR2,
   X_ATTRIBUTE12         IN VARCHAR2,
   X_ATTRIBUTE13         IN VARCHAR2,
   X_ATTRIBUTE14         IN VARCHAR2,
   X_ATTRIBUTE15         IN VARCHAR2,
   X_ORG_ID              IN NUMBER
) IS

   CURSOR C IS
       SELECT ROWID
       FROM PN_VAR_REPORT_DATES_ALL
       WHERE REPORT_DATE_ID = X_REPORT_DATE_ID;

   CURSOR org_id_cur IS
     SELECT org_id
     FROM   PN_VAR_RENTS_ALL
     WHERE  VAR_RENT_ID =  X_VAR_RENT_ID;

   l_org_id NUMBER ;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_REPORT_DATE_ROW (+)');

   -------------------------------------------------------
   -- SELECT the nextval FOR report date id
   -------------------------------------------------------
   IF ( X_REPORT_DATE_ID IS NULL) THEN
      SELECT  pn_var_report_dates_s.nextval
      INTO    X_REPORT_DATE_ID
      FROM    dual;
   END IF;

   IF X_ORG_ID IS NULL THEN
      FOR org_id_rec IN org_id_cur LOOP
         l_org_id := org_id_rec.org_id;
      END LOOP;
   ELSE
      l_org_id := X_ORG_ID;
   END IF;

   INSERT INTO PN_VAR_REPORT_DATES_ALL
   (
      REPORT_DATE_ID,
      GRP_DATE_ID,
      VAR_RENT_ID,
      REPORT_START_DATE,
      REPORT_END_DATE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ORG_ID
   )
   VALUES
   (
     X_REPORT_DATE_ID,
     X_GRP_DATE_ID,
     X_VAR_RENT_ID,
     X_REPORT_START_DATE,
     X_REPORT_END_DATE,
     X_CREATION_DATE,
     X_CREATED_BY,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_ORG_ID
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%NOTFOUND) THEN
     CLOSE c;
     RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_REPORT_DATE_ROW (-)');

END INSERT_REPORT_DATE_ROW;


/*===========================================================================+
 | PROCEDURE
 |    DELETE_REPORT_DATE_ROW
 |
 | DESCRIPTION
 |    DELETE records FROM the PN_VAR_REPORT_DATES
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_GRP_DATE_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : DELETE records FROM the PN_VAR_REPORT_DATES table
 |
 | MODIFICATION HISTORY
 |
 |   10-JAN_2006  Prabhakar  o  Created.
 +===========================================================================*/
PROCEDURE DELETE_REPORT_DATE_ROW (
                              X_VAR_RENT_ID IN NUMBER,
                              X_END_DATE    IN DATE
) IS

  l_date DATE;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_REPORT_DATE_ROW (+)');

   l_date := NVL(X_END_DATE,(TO_DATE('01/01/1776','mm/dd/yyyy')));

   DELETE FROM PN_VAR_REPORT_DATES_ALL
   WHERE VAR_RENT_ID    = X_VAR_RENT_ID
   AND   REPORT_START_DATE > l_date
   AND   REPORT_END_DATE   > l_date;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_REPORT_DATE_ROW (-)');

END DELETE_REPORT_DATE_ROW;


/*============================================================================+
--  NAME         : INSERT_GRP_DATE_ROW
--  DESCRIPTION  : create records in the pn_var_grp_dates table based on
--                 values in pn_var_periods
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS     : IN:
--                    X_ROWID
--                    X_GRP_DATE_ID
--                    X_VAR_RENT_ID
--                    X_PERIOD_ID
--                    X_GRP_START_DATE
--                    X_GRP_END_DATE
--                    X_GROUP_DATE
--                    X_REPTG_DUE_DATE
--                    X_INV_START_DATE
--                    X_INV_END_DATE
--                    X_INVOICE_DATE
--                    X_INV_SCHEDULE_DATE
--                    X_PRORATION_FACTOR
--                    X_ACTUAL_EXP_CODE
--                    X_FORECASTED_EXP_CODE
--                    X_VARIANCE_EXP_CODE
--                 OUT:
--                    X_ROWID
--                    X_GRP_DATE_ID
--
--  REFERENCE    : PN_COMMON.debug()
--  NOTES        : create records in the pn_var_grp_dates table based on values
--                 in pn_var_periods
--  HISTORY      :
--
--  31-AUG-01  DThota   o Created
--  01-NOV-01  DThota   o Added columns PRORATION_FACTOR,ACTUAL_EXP_CODE,
--                        FORECASTED_EXP_CODE,VARIANCE_EXP_CODE
--  19-DEC-01  DThota   o Added columns REPTG_DUE_DATE,INV_SCHEDULE_DATE
--  14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_GRP_DATES with _ALL table.
--  26-OCT-05  piagrawa o Bug#4702709 - Replaced select statement with cursor
--                        and added org id to signature
+=============================================================================*/
PROCEDURE INSERT_GRP_DATE_ROW
(
   X_ROWID               IN OUT NOCOPY VARCHAR2,
   X_GRP_DATE_ID         IN OUT NOCOPY NUMBER,
   X_VAR_RENT_ID         IN NUMBER,
   X_PERIOD_ID           IN NUMBER,
   X_GRP_START_DATE      IN DATE,
   X_GRP_END_DATE        IN DATE,
   X_GROUP_DATE          IN DATE,
   X_REPTG_DUE_DATE      IN DATE,
   X_INV_START_DATE      IN DATE,
   X_INV_END_DATE        IN DATE,
   X_INVOICE_DATE        IN DATE,
   X_INV_SCHEDULE_DATE   IN DATE,
   X_PRORATION_FACTOR    IN NUMBER,
   X_ACTUAL_EXP_CODE     IN VARCHAR2,
   X_FORECASTED_EXP_CODE IN VARCHAR2,
   X_VARIANCE_EXP_CODE   IN VARCHAR2,
   X_CREATION_DATE       IN DATE,
   X_CREATED_BY          IN NUMBER,
   X_LAST_UPDATE_DATE    IN DATE,
   X_LAST_UPDATED_BY     IN NUMBER,
   X_LAST_UPDATE_LOGIN   IN NUMBER,
   X_ORG_ID                 NUMBER
) IS

   CURSOR C IS
       SELECT ROWID
       FROM PN_VAR_GRP_DATES_ALL
       WHERE GRP_DATE_ID = X_GRP_DATE_ID;

   CURSOR org_id_cur IS
     SELECT org_id
     FROM   PN_VAR_RENTS_ALL
     WHERE  VAR_RENT_ID =  X_VAR_RENT_ID;

   l_org_id NUMBER ;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW (+)');

   -------------------------------------------------------
   -- SELECT the nextval FOR group date id
   -------------------------------------------------------
   IF ( X_GRP_DATE_ID IS NULL) THEN
      SELECT  pn_var_grp_dates_s.nextval
      INTO    X_GRP_DATE_ID
      FROM    dual;
   END IF;

   IF X_ORG_ID IS NULL THEN
      FOR org_id_rec IN org_id_cur LOOP
         l_org_id := org_id_rec.org_id;
      END LOOP;
   ELSE
      l_org_id := X_ORG_ID;
   END IF;

   INSERT INTO PN_VAR_GRP_DATES_ALL
   (
      GRP_DATE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      VAR_RENT_ID,
      PERIOD_ID,
      GRP_START_DATE,
      GRP_END_DATE,
      GROUP_DATE,
      REPTG_DUE_DATE,
      INV_START_DATE,
      INV_END_DATE,
      INVOICE_DATE,
      INV_SCHEDULE_DATE,
      PRORATION_FACTOR,
      ACTUAL_EXP_CODE,
      FORECASTED_EXP_CODE,
      VARIANCE_EXP_CODE,
      ORG_ID
   )
   VALUES
   (
      X_GRP_DATE_ID,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_VAR_RENT_ID,
      X_PERIOD_ID,
      X_GRP_START_DATE,
      X_GRP_END_DATE,
      X_GROUP_DATE,
      X_REPTG_DUE_DATE,
      X_INV_START_DATE,
      X_INV_END_DATE,
      X_INVOICE_DATE,
      X_INV_SCHEDULE_DATE,
      round(X_PRORATION_FACTOR,10),
      X_ACTUAL_EXP_CODE,
      X_FORECASTED_EXP_CODE,
      X_VARIANCE_EXP_CODE,
      l_org_id
   );

   OPEN c;
   FETCH c INTO X_ROWID;
   IF (c%NOTFOUND) THEN
     CLOSE c;
     RAISE NO_DATA_FOUND;
   END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW (-)');

END INSERT_GRP_DATE_ROW;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_GRP_DATE_ROW
 |
 | DESCRIPTION
 |    DELETE recORds FROM the PN_VAR_GRP_DATES
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : DELETE recORds FROM the PN_VAR_GRP_DATES table
 |
 | MODIFICATION HISTORY
 |
 |     03-SEP-2001  Daniel Thota  o Created
 |     27-DEC-2001  Daniel Thota  o INcluded parameter x_term_date
 |     14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_GRP_DATES with _ALL table.
 +===========================================================================*/
PROCEDURE DELETE_GRP_DATE_ROW (
  X_VAR_RENT_ID IN NUMBER,
  X_TERM_DATE   IN DATE
) IS

   l_date DATE;

BEGIN

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_GRP_DATE_ROW (+)');

   l_date := NVL(x_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

   DELETE FROM PN_VAR_GRP_DATES_ALL
   WHERE VAR_RENT_ID    = X_VAR_RENT_ID
   AND   GRP_START_DATE > l_date
   AND   GRP_END_DATE   > l_date;


/* in case of a no data found for a given date */
   IF x_term_date IS NULL THEN
      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END IF;

   pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_GRP_DATE_ROW (-)');

END DELETE_GRP_DATE_ROW;

/*=============================================================================+
--  NAME         : CREATE_VAR_RENT_PERIODS
--  DESCRIPTION  : create variable rent periods record in PN_VAR_PERIODS and
--                 corresponding group date/invoice date records in the
--                 PN_VAR_GRP_DATES table for a variable rent record.
--
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN:
--                    p_var_rent_id
--                    p_cumulative_vol
--                    p_comm_date
--                    p_term_date
--                 OUT:
--
--  REFERENCE    : PN_COMMON.debug()
--  NOTES        : create variable rent periods record in pn_var_periods and
--                 corresponding group date/invoice date records in the
--                 pn_var_grp_dates table for a variable rent record.
--                 calls insert_periods_row and insert_grp_date_row procedures
--  HISTORY      :
--
-- 31-AUG-01  Daniel   o Created
-- 17-DEC-01  Daniel   o INcluded parameters p_comm_date
--                       p_term_date to INclude expansion
-- 01-MAR-02  Daniel   o INcluded an additional condition IN the
--                       WHERE clause OF the CURSOR cal_periods
--                       to check FOR the PERIOD_YEAR
-- 31-May-02  AShISh    Fix FOR BUG#2337610, added the condition to validate
--                       GL CalENDar start date should be beFORe Variable Rent
--                       Commencement date
-- 15-SEP-02  Kiran    o Changed the CURSORs FOR creatINg periods, group dates.
--                       Fix FOR bug 2392799.
-- 16-nov-02  Kiran    o Replaced (substr(TO_CHAR(p_schedule_date),1,2)) with
--                       to_number(TO_CHAR(p_schedule_date,'dd') WHEREever it
--                       occurs.
-- 16-Mar-20  Srini    o Added p_create_flag with default 'Y' for VR extension
--                       support
-- 01-MAR-04  Vivek    o Fix FOR bug#4215699. ModIFied the WHERE clause OF
--                       CURSOR cal_periods to add END_date >= p_vr_comm_date
--                       AND remove the period_year condition.
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL tbl
-- 26-OCT-05  piagrawa o Bug#4702709 - Passed org id in insert row handler.
--                       pass org id to PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
-- 28-nov-05  pikhar   o Replaced pn_var_periods with _ALL table
-- 11-JAN-07  Pseeram  o Added the call to cretae_report_dates
--  21-MAR-07  Lbala    o Bug # 5937888 - added code to change reptg_due_date
+=============================================================================*/
PROCEDURE CREATE_VAR_RENT_PERIODS(p_var_rent_id    in NUMBER,
                                  p_cumulative_vol in VARCHAR2,
                                  p_comm_date      in DATE,
                                  p_term_date      in DATE,
                                  p_create_flag    IN VARCHAR2 DEFAULT 'Y' )
IS

p_creation_date       DATE    := SYSDATE;
p_created_by          NUMBER  := NVL (fnd_profile.VALUE ('USER_ID'), 0);
p_cal_start_date      DATE    := TO_DATE('01/01/1776','mm/dd/yyyy'); --dates from calendar
p_cal_end_date        DATE    := TO_DATE('01/01/1776','mm/dd/yyyy'); --dates from calendar
p_cal_start_date_orig DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
-- to later update start date if date set up in calendar is different from
-- actual start date in the variable rent
p_cal_end_date_orig  DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_period_id          NUMBER  := null;
p_start_date         DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
/* first day of the month of p_start_date*/
p_start_date1        DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
/* first day of the quarter of p_start_date*/
p_start_date3        DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
/* first day of the semiannual period of p_start_date*/
p_start_date6        DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
/* first day of the annual period of p_start_date*/
p_start_date12       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
p_end_date           DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');  --dates from periods
p_per_start_date     DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_per_end_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_grp_start_date     DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_grp_end_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_group_date         DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_inv_start_date     DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_inv_end_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_invoice_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_vr_comm_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
/* first day of the month given VR commencement date p_vr_comm_date*/
p_vr_comm_date1      DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
/* first day of the quarter given VR commencement date p_vr_comm_date*/
p_vr_comm_date3      DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
/* first day of the semiannual period given VR commencement date p_vr_comm_date*/
p_vr_comm_date6      DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
/* first day of the annual period given VR commencement date p_vr_comm_date*/
p_vr_comm_date12     DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
p_vr_term_date       DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');
/* first day of the month given VR termination date p_vr_term_date*/
p_vr_term_date1      DATE    := TO_DATE('01/01/1776','mm/dd/yyyy');

p_period_set_name    VARCHAR2(30):= NULL;
p_period_type        VARCHAR2(15):= NULL;
p_per_freq_code      NUMBER        := NULL;
p_reptg_freq_code    NUMBER        := NULL;
p_reptg_day_of_month NUMBER        := 0;
p_reptg_days_after   NUMBER        := 0;
p_due_date           DATE          := TO_DATE('01/01/1776','mm/dd/yyyy');
p_invg_freq_code     NUMBER        := NULL;
p_invg_day_of_month  NUMBER        := 0;
p_invg_days_after    NUMBER        := 0;
p_schedule_date      DATE          := TO_DATE('01/01/1776','mm/dd/yyyy');

l_rowId                VARCHAR2(18):= NULL;
l_periodId             NUMBER      := NULL;
l_grpDateId            NUMBER      := NULL;
l_periodNum            NUMBER      := NULL;
l_counter              NUMBER      := 0;
l_notfound             BOOLEAN;
tot_per_proration_days NUMBER      := 0;
per_proration_days     NUMBER      := 0;
tot_grp_proration_days NUMBER      := 0;
grp_proration_days     NUMBER      := 0;
p_proration_factor     NUMBER      := 0;

l_use_gl_calendar      VARCHAR2(1) := NULL;
l_year_start_date      DATE        := NULL;
l_is_partial_period    BOOLEAN     := FALSE;
l_partial_period       VARCHAR2(1) := 'N';

CURSOR cal_periods IS
  SELECT MIN(start_date) start_date, MAX(end_date) end_date
  FROM     gl_periods
  WHERE    period_set_name = p_period_set_name
  AND      start_date      <= p_vr_term_date
  AND      period_type = p_period_type
  AND      period_year >= TO_NUMBER(TO_CHAR(TO_DATE(p_vr_comm_date1,'DD/MM/RRRR'),'RRRR'))
  GROUP BY period_year
  ORDER BY start_date;

CURSOR group_date_mon IS
  SELECT   MIN(start_date) start_date, MAX(END_date) END_date
  FROM     gl_periods
  WHERE    period_set_name = p_period_set_name
  AND      start_date      <= p_vr_term_date
  AND      end_date        >= p_vr_comm_date
  AND      period_type = p_period_type
  AND      adjustment_period_flag = 'N'
  GROUP BY period_year, quarter_num, period_num
  ORDER BY start_date,end_date;

CURSOR group_date_qtr IS
  SELECT   MIN(start_date) start_date,  MAX(end_date) end_date
  FROM     gl_periods
  WHERE    period_set_name = p_period_set_name
  AND      start_date      <= p_vr_term_date
  AND      end_date      >= p_vr_comm_date
  AND      quarter_num     IN(1,2,3,4)
  AND      period_type = p_period_type
  GROUP BY period_year, quarter_num
  ORDER BY start_date;

CURSOR group_date_sa IS
  SELECT   MIN(g1.start_date) start_date
         ,MAX(g2.end_date) end_date
  FROM     gl_periods g1, gl_periods g2
  WHERE    g1.period_set_name(+) = p_period_set_name
  AND      g2.period_set_name = p_period_set_name
  AND      g1.start_date(+)     <= p_vr_term_date
  AND      g2.end_date        >=  p_vr_comm_date
  AND      g1.quarter_num(+) = 1
  AND      g2.quarter_num = 2
  AND      g1.period_year(+) = g2.period_year
  AND      g1.start_date IS NOT NULL
  AND      g2.end_date IS NOT NULL
  AND      g1.period_type = p_period_type
  AND      g2.period_type = p_period_type
  GROUP BY g2.period_year
  UNION
  SELECT   MIN(g1.start_date) start_date
         ,MAX(g2.end_date) end_date
  FROM     gl_periods g1, gl_periods g2
  WHERE    g1.period_set_name(+) = p_period_set_name
  AND      g2.period_set_name = p_period_set_name
  AND      g1.start_date(+)     <= p_vr_term_date
  AND      g2.end_date        >=  p_vr_comm_date
  AND      g1.quarter_num(+) = 3
  AND      g2.quarter_num = 4
  AND      g1.period_year (+)= g2.period_year
  AND      g1.start_date IS NOT NULL
  AND      g2.end_date IS NOT NULL
  AND      g1.period_type = p_period_type
  AND      g2.period_type = p_period_type
  GROUP BY g2.period_year
  ORDER BY 1;

CURSOR group_date_ann IS
  SELECT MIN(start_date) start_date,MAX(end_date) end_date
  FROM     gl_periods
  WHERE    period_set_name = p_period_set_name
  AND      start_date      <= p_vr_term_date
  AND      end_date        >= p_vr_comm_date
  AND    period_type = p_period_type
  GROUP BY period_year
  ORDER BY start_date;

CURSOR period_dates IS
  SELECT period_id,start_date, end_date, proration_factor
  FROM   pn_var_periods
  WHERE  var_rent_id  = p_var_rent_id
  AND    start_date   <= p_vr_term_date
  AND    end_date   >= p_vr_comm_date
  ORDER BY start_date;

/* Fetches the group id which starts on a specified date for a VR agreement */
CURSOR group_cur (p_start_date DATE) IS
  SELECT grp_end_date, grp_date_id
  FROM   pn_var_grp_dates_all
  WHERE  var_rent_id = p_var_rent_id
  AND    grp_start_date  = p_start_date;

/* Fetches the period id which starts on a specified date for a VR agreement */
CURSOR period_cur (p_start_date DATE) IS
  SELECT period_id, end_date, status
  FROM   pn_var_periods_all
  WHERE  var_rent_id = p_var_rent_id
  AND    start_date  = p_start_date;

/* Fetches the group id in which a specified invoice date lies for a VR agreement */
CURSOR invoice_cur(p_inv_start_date DATE, p_inv_end_date DATE, p_period_id NUMBER) IS
  SELECT inv_start_date, inv_end_date
  FROM pn_var_grp_dates_all
  WHERE inv_start_date = p_inv_start_date
  AND inv_end_date     = p_inv_end_date
  AND period_id        = p_period_id;

l_org_id                NUMBER;
l_period_exists         VARCHAR2(1)   := 'N';
l_group_exists          VARCHAR2(1)   := 'N';
l_invoice_exists          VARCHAR2(1)   := 'N';
l_period_id             NUMBER        := NULL;
l_end_date              DATE := NULL;
l_status                pn_var_periods_all.status%TYPE;
l_grp_date_id           NUMBER;
l_grp_end_date DATE := NULL;


BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS (+)');
  pnp_debug_pkg.debug ('p_var_rent_id   '||p_var_rent_id);
  pnp_debug_pkg.debug ('p_cumulative_vol'||p_cumulative_vol);
  pnp_debug_pkg.debug ('p_comm_date     '||p_comm_date);
  pnp_debug_pkg.debug ('p_term_date     '||p_term_date);
  pnp_debug_pkg.debug ('p_create_flag   '||p_create_flag);

  -- Get dates/info, GL calendar used from Variable Rent record

  SELECT vr.commencement_date,
         vr.termination_date,
         decode(vr.proration_days,'999',365,
                                  vr.proration_days),
         decode(cal.period_freq_code,'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     null),
         decode(cal.reptg_freq_code, 'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     null),
         cal.reptg_day_of_month,
         cal.reptg_days_after,
         decode(cal.invg_freq_code,  'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     null),
         cal.invg_day_of_month,
         cal.invg_days_after,
         cal.gl_period_set_name,
         cal.period_type,
         cal.use_gl_calendar,
         cal.year_start_date,
         vr.org_id
  INTO   p_vr_comm_date,
         p_vr_term_date,
         tot_per_proration_days,
         p_per_freq_code,
         p_reptg_freq_code,
         p_reptg_day_of_month,
         p_reptg_days_after,
         p_invg_freq_code,
         p_invg_day_of_month,
         p_invg_days_after,
         p_period_set_name,
         p_period_type,
         l_use_gl_calendar,
         l_year_start_date,
         l_org_id
  FROM   PN_VAR_RENTS_ALL vr, PN_VAR_RENT_DATES_ALL cal
  WHERE  vr.var_rent_id  = p_var_rent_id
  AND    cal.var_rent_id = vr.var_rent_id;

  ----------------------------------
  -- FOR expansion OF VR
  ----------------------------------
  IF (p_comm_date IS NOT NULL) THEN
    p_vr_comm_date := p_comm_date;
  END IF;

  IF (p_term_date IS NOT NULL) THEN
    p_vr_term_date := p_term_date;
  END IF;

  p_vr_comm_date1 := FIRST_DAY(p_vr_comm_date);
  p_vr_term_date1 := FIRST_DAY(p_vr_term_date);
  IF (p_comm_date IS NOT NULL) THEN
    p_vr_comm_date3 := p_vr_comm_date1-80;
    p_vr_comm_date6 := p_vr_comm_date1-170;
    p_vr_comm_date12:= p_vr_comm_date1-360;
  ELSE
    p_vr_comm_date3 := p_vr_comm_date1;
    p_vr_comm_date6 := p_vr_comm_date1;
    p_vr_comm_date12:= p_vr_comm_date1;
  END IF;

  -- Get dates from associated GL Calendar

  SELECT MIN(start_date), MAX(end_date)
  INTO   p_cal_start_date, p_cal_end_date
  FROM   gl_periods
  WHERE  period_set_name = p_period_set_name
  AND    period_type = p_period_type;

  ----------------------------------
  -- For expansion of VR
  ----------------------------------
  IF (p_comm_date IS NOT NULL) THEN

    SELECT MIN(start_date), MAX(end_date)
    INTO   p_cal_start_date, p_cal_end_date
    FROM   gl_periods
    WHERE  period_set_name = p_period_set_name
    AND    period_type = p_period_type
    AND    start_date  >= p_comm_date
    AND    end_date    >= p_comm_date
    AND    start_date  <= p_term_date;

  END IF;
  ----------------------------------

  p_cal_start_date_orig := p_cal_start_date;
  p_cal_end_date_orig   := p_cal_end_date;

  IF p_cal_end_date < p_vr_term_date THEN
    fnd_message.set_name ('PN','PN_VAR_GLCAL_SHORT');
    APP_EXCEPTION.Raise_Exception;
  END IF;

  IF p_cal_start_date > p_vr_comm_date THEN
    fnd_message.set_name ('PN','PN_VAR_GLCAL_LATER');
    APP_EXCEPTION.Raise_Exception;
  END IF;

  IF p_vr_term_date < p_cal_end_date THEN
    p_cal_end_date     := p_vr_term_date;
  END IF;
  p_cal_start_date      := p_vr_comm_date;

  -- Create the period records

  IF NVL(p_create_flag, 'Y') = 'Y' THEN

    WHILE p_per_end_date < p_cal_end_date LOOP

      l_counter :=  0;
      FOR cal_periods_rec in cal_periods LOOP

        l_counter := cal_periods%ROWCOUNT;
        l_period_exists := 'N';
        p_proration_factor := (cal_periods_rec.end_date-cal_periods_rec.start_date)+1;

        IF (l_counter =  1) THEN
          p_per_start_date := p_cal_start_date;
        ELSE
          p_per_start_date := cal_periods_rec.start_date;
        END IF;

        IF (cal_periods_rec.end_date > p_vr_term_date) THEN
          p_per_end_date   := p_cal_end_date;
          l_partial_period := 'Y';
        ELSE
          p_per_end_date   := cal_periods_rec.end_date;
          l_partial_period := 'N';
        END IF;

        /* Check if the period with calculated start date as above
        already exists in database */
        FOR period_rec IN period_cur(p_per_start_date)  LOOP
          l_period_id := period_rec.period_id;
          l_end_date := period_rec.end_date;
          l_status   := period_rec.status;
          l_period_exists := 'Y';
          pnp_debug_pkg.debug(' period exists ...'||l_periodId);
          pnp_debug_pkg.debug('');
        END LOOP;

        IF l_period_exists = 'N' THEN  /* Insert the period if it does not exist */
          --call to insert into PN_VAR_PERIODS;

          pnp_debug_pkg.debug(' period exists ...N');
          PN_VAR_RENT_PKG.INSERT_PERIODS_ROW
          (X_ROWID              => l_rowId,
          X_PERIOD_ID          => l_periodId,
          X_PERIOD_NUM         => l_periodNum,
          X_VAR_RENT_ID        => p_var_rent_id,
          X_START_DATE         => p_per_start_date,
          X_END_DATE           => p_per_end_date,
          X_PRORATION_FACTOR   => p_proration_factor,
          X_PARTIAL_PERIOD     => l_partial_period,
          X_ATTRIBUTE_CATEGORY => NULL,
          X_ATTRIBUTE1         => NULL,
          X_ATTRIBUTE2         => NULL,
          X_ATTRIBUTE3         => NULL,
          X_ATTRIBUTE4         => NULL,
          X_ATTRIBUTE5         => NULL,
          X_ATTRIBUTE6         => NULL,
          X_ATTRIBUTE7         => NULL,
          X_ATTRIBUTE8         => NULL,
          X_ATTRIBUTE9         => NULL,
          X_ATTRIBUTE10        => NULL,
          X_ATTRIBUTE11        => NULL,
          X_ATTRIBUTE12        => NULL,
          X_ATTRIBUTE13        => NULL,
          X_ATTRIBUTE14        => NULL,
          X_ATTRIBUTE15        => NULL,
          X_CREATION_DATE      => p_creation_date,
          X_CREATED_BY          => p_created_by,
          X_LAST_UPDATE_DATE   => p_creation_date,
          X_LAST_UPDATED_BY    => p_created_by,
          X_LAST_UPDATE_LOGIN  => p_created_by
          );

          l_rowId            := NULL;
          l_periodId         := NULL;
          l_periodNum        := NULL;
          pnp_debug_pkg.debug('period inserted is ...'||l_periodId);

        ELSE /* period exists in the database */

          pnp_debug_pkg.debug('New Period Start Date:'||p_per_start_date);
          pnp_debug_pkg.debug('New Period End Date:'||p_per_end_date);
          pnp_debug_pkg.debug('l_end_date:'||l_end_date);

          /* Check if the period in the database is a partial period */
          IF p_per_end_date = l_end_date THEN

            pnp_debug_pkg.debug('period end date is equsal to period in data base ..');

            /* Make the period as active if it is inactive */
            IF  l_status = pn_var_rent_pkg.status THEN

              pnp_debug_pkg.debug('period is inactive ..'||l_period_id);
              UPDATE pn_var_periods_all
              SET status = NULL
              WHERE period_id = l_period_id;

            END IF;

          ELSIF  p_per_end_date > l_end_date THEN /* period is partial */

            /* Updte the end date and partial flag for the period */
            UPDATE pn_var_periods_all
            SET end_date = p_per_end_date,
                partial_period = l_partial_period,
                status = NULL
            WHERE period_id = l_period_id;

          END IF;

        END IF;

      END LOOP;

    END LOOP;

    -- for each period record created above create corresponding group date records

    FOR per_date_rec IN period_dates LOOP
      p_start_date := per_date_rec.start_date;
      p_start_date1:= FIRST_DAY(per_date_rec.start_date);
      ----------------------------------
      -- For expansion of VR
      ----------------------------------
      IF (p_comm_date IS NOT NULL) THEN
        p_start_date3 := p_start_date1-80;
        p_start_date6 := p_start_date1-170;
        p_start_date12:= p_start_date1-360;
      ELSE
        p_start_date3 := p_start_date1;
        p_start_date6 := p_start_date1;
        p_start_date12:= p_start_date1;
      END IF;
      ----------------------------------
      p_end_date   := per_date_rec.end_date;
      p_period_id  := per_date_rec.period_id;
      p_proration_factor  := per_date_rec.proration_factor;

      WHILE p_grp_end_date < per_date_rec.end_date LOOP
      -- Open appropriate cursors based on the reporting frequency to insert group_date

        IF (p_reptg_freq_code = 1) THEN

          /* l_counter :=0; */

          FOR group_date_mon_rec IN group_date_mon LOOP

            /* l_counter := group_date_mon%ROWCOUNT; */
            l_group_exists := 'N';

            IF group_date_mon_rec.start_date < per_date_rec.start_date THEN
              p_grp_start_date := p_start_date;
            ELSE
              p_grp_start_date := group_date_mon_rec.start_date;
            END IF;

            IF (group_date_mon_rec.end_date >= p_vr_term_date) THEN
              p_grp_end_date   := per_date_rec.end_date;
            ELSE
              p_grp_end_date   := group_date_mon_rec.end_date;
            END IF;

            p_group_date := group_date_mon_rec.start_date;

            IF (p_reptg_day_of_month IS NOT NULL) THEN
              p_due_date  := (ADD_MONTHS(FIRST_DAY(p_grp_end_date),1)-1)+p_reptg_day_of_month;
            ELSE
              p_due_date  := p_grp_end_date+nvl(p_reptg_days_after,0);
            END IF;

            p_proration_factor := ((p_grp_end_date - p_grp_start_date) + 1)/
                             ((group_date_mon_rec.end_date - group_date_mon_rec.start_date) + 1);

            ------------------------------------------------------------
            --Eliminates all other records from the group_date_mon cursor
            --which do not belong to the period in period_dates cursor
            ------------------------------------------------------------

            IF ((group_date_mon_rec.start_date <= per_date_rec.end_date) AND
               (group_date_mon_rec.end_date >= p_start_date)) THEN

              /* Check if the group in PL/SQL table with a specified start date
              already exists in database */
              FOR group_rec IN group_cur(p_grp_start_date)  LOOP
                l_grp_date_id  := group_rec.grp_date_id;
                l_grp_end_date := group_rec.grp_end_date;
                l_group_exists := 'Y';
              END LOOP;

              IF l_group_exists = 'N' THEN

                /* group does not exist in the database and needs to be added */
                pnp_debug_pkg.debug ('l_group_exists = N');
                ------------------------------------------------------------
                --call to insert into PN_VAR_GRP_DATES;
                ------------------------------------------------------------
                PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
                (X_ROWID               => l_rowId,
                 X_GRP_DATE_ID         => l_grpDateId,
                 X_VAR_RENT_ID         => p_var_rent_id,
                 X_PERIOD_ID           => p_period_id,
                 X_GRP_START_DATE      => p_grp_start_date,
                 X_GRP_END_DATE        => p_grp_end_date,
                 X_GROUP_DATE          => p_group_date,
                 X_REPTG_DUE_DATE      => p_due_date,
                 X_INV_START_DATE      => p_inv_start_date,
                 X_INV_END_DATE        => p_inv_end_date,
                 X_INVOICE_DATE        => p_invoice_date,
                 X_INV_SCHEDULE_DATE   => p_schedule_date,
                 X_PRORATION_FACTOR    => p_proration_factor,
                 X_ACTUAL_EXP_CODE     => 'N',
                 X_FORECASTED_EXP_CODE => 'N',
                 X_VARIANCE_EXP_CODE   => 'N',
                 X_CREATION_DATE       => p_creation_date,
                 X_CREATED_BY          => p_created_by,
                 X_LAST_UPDATE_DATE    => p_creation_date,
                 X_LAST_UPDATED_BY     => p_created_by,
                 X_LAST_UPDATE_LOGIN   => p_created_by
                );

                pnp_debug_pkg.debug ('group dte id of group added ....'||l_grpDateId);
                l_rowId        := NULL;
                l_grpDateId    := NULL;

              ELSE
                pnp_debug_pkg.debug ('l_group_exists = Y');
                /* Check if the group in the database is a partial or if the new group is partial */
                IF p_grp_end_date <> l_grp_end_date THEN

                  pnp_debug_pkg.debug ('updating end date of group '||l_grp_date_id);
                  pnp_debug_pkg.debug ('updating end date as '||p_grp_end_date);
                  pnp_debug_pkg.debug ('updating proration factor as '||p_proration_factor);
                  pnp_debug_pkg.debug ('updating due date as '||p_due_date);
                  /* Updte the end date and proration factor for the group */
                  UPDATE pn_var_grp_dates_all
                  SET grp_end_date = p_grp_end_date,
                      proration_Factor = round(p_proration_factor,10),
                      reptg_due_date = p_due_date      --Bug # 5937888
                  WHERE grp_date_id = l_grp_date_id;

                END IF;
              END IF;

            END IF;

          END LOOP;

        ELSIF (p_reptg_freq_code = 3) THEN

          /* l_counter              := 0; */

          FOR group_date_qtr_rec IN group_date_qtr LOOP

            /* l_counter           := group_date_qtr%ROWCOUNT; */

            l_group_exists := 'N';

            IF group_date_qtr_rec.start_date < per_date_rec.start_date THEN
              p_grp_start_date := p_start_date;
            ELSE
              p_grp_start_date := group_date_qtr_rec.start_date;
            END IF;

            IF (group_date_qtr_rec.end_date >= p_vr_term_date) THEN
              p_grp_end_date   := per_date_rec.end_date;
            ELSE
              p_grp_end_date   := group_date_qtr_rec.end_date;
            END IF;

            p_group_date        := group_date_qtr_rec.start_date;

            IF (p_reptg_day_of_month IS NOT NULL) THEN
              p_due_date  := (ADD_MONTHS(FIRST_DAY(p_grp_end_date),1)-1)+p_reptg_day_of_month;
            ELSE
              p_due_date  := p_grp_end_date+nvl(p_reptg_days_after,0);
            END IF;

            p_proration_factor := ((p_grp_end_date - p_grp_start_date) + 1)/
                             ((group_date_qtr_rec.end_date - group_date_qtr_rec.start_date) + 1);

            ------------------------------------------------------------
            --Eliminates all other records from the group_date_qtr cursor
            --which do not belong to the period in period_dates cursor
            ------------------------------------------------------------
            IF ((group_date_qtr_rec.start_date <= per_date_rec.end_date) AND
               (group_date_qtr_rec.end_date >= p_start_date)) THEN

              /* Check if the group in PL/SQL table with a specified start date
              already exists in database */
              FOR group_rec IN group_cur(p_grp_start_date)  LOOP
                l_grp_date_id  := group_rec.grp_date_id;
                l_grp_end_date := group_rec.grp_end_date;
                l_group_exists := 'Y';
              END LOOP;

              IF l_group_exists = 'N' THEN

                /* group does not exist in the database and needs to be added */
                pnp_debug_pkg.debug ('l_group_exists = N');

                ------------------------------------------------------------
                --call to insert into PN_VAR_GRP_DATES;
                ------------------------------------------------------------
                PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
                (X_ROWID               => l_rowId,
                 X_GRP_DATE_ID         => l_grpDateId,
                 X_VAR_RENT_ID         => p_var_rent_id,
                 X_PERIOD_ID           => p_period_id,
                 X_GRP_START_DATE      => p_grp_start_date,
                 X_GRP_END_DATE        => p_grp_end_date,
                 X_GROUP_DATE          => p_group_date,
                 X_REPTG_DUE_DATE      => p_due_date,
                 X_INV_START_DATE      => p_inv_start_date,
                 X_INV_END_DATE        => p_inv_end_date,
                 X_INVOICE_DATE        => p_invoice_date,
                 X_INV_SCHEDULE_DATE   => p_schedule_date,
                 X_PRORATION_FACTOR    => p_proration_factor,
                 X_ACTUAL_EXP_CODE     => 'N',
                 X_FORECASTED_EXP_CODE => 'N',
                 X_VARIANCE_EXP_CODE   => 'N',
                 X_CREATION_DATE       => p_creation_date,
                 X_CREATED_BY          => p_created_by,
                 X_LAST_UPDATE_DATE    => p_creation_date,
                 X_LAST_UPDATED_BY     => p_created_by,
                 X_LAST_UPDATE_LOGIN   => p_created_by
                );

                pnp_debug_pkg.debug ('group dte id of group added ....'||l_grpDateId);
                l_rowId        := NULL;
                l_grpDateId    := NULL;

              ELSE
                pnp_debug_pkg.debug ('l_group_exists = Y');
                /* Check if the group in the database is a partial or if the new group is partial */
                IF p_grp_end_date <> l_grp_end_date THEN

                  pnp_debug_pkg.debug ('updating end date of group '||l_grp_date_id);
                  pnp_debug_pkg.debug ('updating end date as '||p_grp_end_date);
                  pnp_debug_pkg.debug ('updating proration factor as '||p_proration_factor);
                  pnp_debug_pkg.debug ('updating due date as '||p_due_date);
                  /* Updte the end date and proration factor for the group */
                  UPDATE pn_var_grp_dates_all
                  SET grp_end_date = p_grp_end_date,
                      proration_Factor = round(p_proration_factor,10),
                      reptg_due_date = p_due_date     --Bug # 5937888
                  WHERE grp_date_id = l_grp_date_id;

                END IF;

              END IF;

            END IF;

          END LOOP;

        ELSIF (p_reptg_freq_code = 6) THEN

          /* l_counter                := 0; */

          FOR group_date_sa_rec IN group_date_sa LOOP

            /* l_counter             := group_date_sa%ROWCOUNT; */

            l_group_exists := 'N';

            IF group_date_sa_rec.start_date < per_date_rec.start_date THEN
              p_grp_start_date := p_start_date;
            ELSE
              p_grp_start_date := group_date_sa_rec.start_date;
            END IF;

            IF (group_date_sa_rec.end_date > p_end_date) THEN
              p_grp_end_date   := per_date_rec.end_date;
            ELSE
              p_grp_end_date   := group_date_sa_rec.end_date;
            END IF;

            p_group_date        := group_date_sa_rec.start_date;

            IF (p_reptg_day_of_month IS NOT NULL) THEN
              p_due_date  := (ADD_MONTHS(FIRST_DAY(p_grp_end_date),1)-1)+p_reptg_day_of_month;
            ELSE
              p_due_date  := p_grp_end_date+nvl(p_reptg_days_after,0);
            END IF;

            p_proration_factor := ((p_grp_end_date - p_grp_start_date) + 1)/
                             ((group_date_sa_rec.end_date - group_date_sa_rec.start_date) + 1);

            ------------------------------------------------------------
            --Eliminates all other records from the group_date_sa cursor
            --which do not belong to the period in period_dates cursor
            ------------------------------------------------------------
            IF ((group_date_sa_rec.start_date <= per_date_rec.end_date) AND
               (group_date_sa_rec.end_date >= p_start_date)) THEN

              /* Check if the group in PL/SQL table with a specified start date
              already exists in database */
              FOR group_rec IN group_cur(p_grp_start_date)  LOOP
                l_grp_date_id  := group_rec.grp_date_id;
                l_grp_end_date := group_rec.grp_end_date;
                l_group_exists := 'Y';
              END LOOP;

              IF l_group_exists = 'N' THEN

                /* group does not exist in the database and needs to be added */
                pnp_debug_pkg.debug ('l_group_exists = N');

                ------------------------------------------------------------
                --call to insert into PN_VAR_GRP_DATES;
                ------------------------------------------------------------

                PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
                (X_ROWID               => l_rowId,
                 X_GRP_DATE_ID         => l_grpDateId,
                 X_VAR_RENT_ID         => p_var_rent_id,
                 X_PERIOD_ID           => p_period_id,
                 X_GRP_START_DATE      => p_grp_start_date,
                 X_GRP_END_DATE        => p_grp_end_date,
                 X_GROUP_DATE          => p_group_date,
                 X_REPTG_DUE_DATE      => p_due_date,
                 X_INV_START_DATE      => p_inv_start_date,
                 X_INV_END_DATE        => p_inv_end_date,
                 X_INVOICE_DATE        => p_invoice_date,
                 X_INV_SCHEDULE_DATE   => p_schedule_date,
                 X_PRORATION_FACTOR    => p_proration_factor,
                 X_ACTUAL_EXP_CODE     => 'N',
                 X_FORECASTED_EXP_CODE => 'N',
                 X_VARIANCE_EXP_CODE   => 'N',
                 X_CREATION_DATE       => p_creation_date,
                 X_CREATED_BY          => p_created_by,
                 X_LAST_UPDATE_DATE    => p_creation_date,
                 X_LAST_UPDATED_BY     => p_created_by,
                 X_LAST_UPDATE_LOGIN   => p_created_by
                );

                pnp_debug_pkg.debug ('group dte id of group added ....'||l_grpDateId);
                l_rowId        := NULL;
                l_grpDateId    := NULL;

              ELSE
                pnp_debug_pkg.debug ('l_group_exists = Y');
                /* Check if the group in the database is a partial or if the new group is partial */
                IF p_grp_end_date <> l_grp_end_date THEN

                  pnp_debug_pkg.debug ('updating end date of group '||l_grp_date_id);
                  pnp_debug_pkg.debug ('updating end date as '||p_grp_end_date);
                  pnp_debug_pkg.debug ('updating proration factor as '||p_proration_factor);
                  pnp_debug_pkg.debug ('updating due date as '||p_due_date);
                  /* Updte the end date and proration factor for the group */
                  UPDATE pn_var_grp_dates_all
                  SET grp_end_date = p_grp_end_date,
                      proration_Factor = round(p_proration_factor,10),
                      reptg_due_date = p_due_date     --Bug # 5937888
                  WHERE grp_date_id = l_grp_date_id;

                END IF;

              END IF;

            END IF;

          END LOOP;

        ELSE

          /* l_counter      := 0; */

          FOR group_date_ann_rec IN group_date_ann LOOP

            /* l_counter             := group_date_ann%ROWCOUNT; */

            l_group_exists := 'N';

            IF group_date_ann_rec.start_date < per_date_rec.start_date THEN
              p_grp_start_date := p_start_date;
            ELSE
              p_grp_start_date := group_date_ann_rec.start_date;
            END IF;

            IF (group_date_ann_rec.end_date > p_end_date) THEN
              p_grp_end_date   := per_date_rec.end_date;
            ELSE
              p_grp_end_date   := group_date_ann_rec.end_date;
            END IF;

            p_group_date     := group_date_ann_rec.start_date;

            IF (p_reptg_day_of_month IS NOT NULL) THEN
              p_due_date  := (ADD_MONTHS(FIRST_DAY(p_grp_end_date),1)-1)+p_reptg_day_of_month;
            ELSE
              p_due_date  := p_grp_end_date+nvl(p_reptg_days_after,0);
            END IF;

            p_proration_factor := ((p_grp_end_date - p_grp_start_date) + 1)/
                             ((group_date_ann_rec.end_date - group_date_ann_rec.start_date) + 1);

            ------------------------------------------------------------
            --Eliminates all other records from the group_date_ann cursor
            --which do not belong to the period in period_dates cursor
            ------------------------------------------------------------
            IF ((group_date_ann_rec.start_date <= per_date_rec.end_date) AND
               (group_date_ann_rec.end_date >= p_start_date)) THEN

              /* Check if the group in PL/SQL table with a specified start date
              already exists in database */
              FOR group_rec IN group_cur(p_grp_start_date)  LOOP
                l_grp_date_id  := group_rec.grp_date_id;
                l_grp_end_date := group_rec.grp_end_date;
                l_group_exists := 'Y';
              END LOOP;

              IF l_group_exists = 'N' THEN

                /* group does not exist in the database and needs to be added */
                pnp_debug_pkg.debug ('l_group_exists = N');

                ------------------------------------------------------------
                --call to insert into PN_VAR_GRP_DATES;
                ------------------------------------------------------------
                PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
                (X_ROWID               => l_rowId,
                 X_GRP_DATE_ID         => l_grpDateId,
                 X_VAR_RENT_ID         => p_var_rent_id,
                 X_PERIOD_ID           => p_period_id,
                 X_GRP_START_DATE      => p_grp_start_date,
                 X_GRP_END_DATE        => p_grp_end_date,
                 X_GROUP_DATE          => p_group_date,
                 X_REPTG_DUE_DATE      => p_due_date,
                 X_INV_START_DATE      => p_inv_start_date,
                 X_INV_END_DATE        => p_inv_end_date,
                 X_INVOICE_DATE        => p_invoice_date,
                 X_INV_SCHEDULE_DATE   => p_schedule_date,
                 X_PRORATION_FACTOR    => p_proration_factor,
                 X_ACTUAL_EXP_CODE     => 'N',
                 X_FORECASTED_EXP_CODE => 'N',
                 X_VARIANCE_EXP_CODE   => 'N',
                 X_CREATION_DATE       => p_creation_date,
                 X_CREATED_BY          => p_created_by,
                 X_LAST_UPDATE_DATE    => p_creation_date,
                 X_LAST_UPDATED_BY     => p_created_by,
                 X_LAST_UPDATE_LOGIN   => p_created_by
                );

                pnp_debug_pkg.debug ('group dte id of group added ....'||l_grpDateId);
                l_rowId        := NULL;
                l_grpDateId    := NULL;

              ELSE
                pnp_debug_pkg.debug ('l_group_exists = Y');
                 /* Check if the group in the database is a partial or if the new group is partial */
                IF p_grp_end_date <> l_grp_end_date THEN

                  pnp_debug_pkg.debug ('updating end date of group '||l_grp_date_id);
                  pnp_debug_pkg.debug ('updating end date as '||p_grp_end_date);
                  pnp_debug_pkg.debug ('updating proration factor as '||p_proration_factor);
                  pnp_debug_pkg.debug ('updating due date as '||p_due_date);
                  /* Updte the end date and proration factor for the group */
                  UPDATE pn_var_grp_dates_all
                  SET grp_end_date = p_grp_end_date,
                      proration_Factor = round(p_proration_factor,10),
                      reptg_due_date = p_due_date   --Bug # 5937888
                  WHERE grp_date_id = l_grp_date_id;

                END IF;

              END IF;

            END IF;

          END LOOP;

        END IF;

      END LOOP;

    END LOOP;

    PN_VAR_RENT_PKG.delete_report_date_row(p_var_rent_id, NULL);
    PN_VAR_RENT_PKG.create_report_dates (p_var_rent_id);

  END IF;    --p_create_flag

  -- for each group date record created above update with corresponding invoice dates

  FOR per_date_rec IN period_dates LOOP

    p_start_date := per_date_rec.start_date;
    p_start_date1:= FIRST_DAY(per_date_rec.start_date);
    IF (p_comm_date IS NOT NULL) THEN
      p_start_date3 := p_start_date1-80;
      p_start_date6 := p_start_date1-170;
      p_start_date12:= p_start_date1-360;
    ELSE
      p_start_date3 := p_start_date1;
      p_start_date6 := p_start_date1;
      p_start_date12:= p_start_date1;
    END IF;
    p_period_id  := per_date_rec.period_id;

    WHILE p_inv_end_date < per_date_rec.end_date LOOP
    -- Open appropriate cursors based on the invoicing frequency to update invoice_date

      IF (p_invg_freq_code = 1) THEN

        /* l_counter              :=0;*/

        FOR group_date_mon_rec IN group_date_mon LOOP

          l_invoice_exists := 'N';
          /* l_counter := group_date_mon%ROWCOUNT; */

          IF group_date_mon_rec.start_date < per_date_rec.start_date THEN
            p_inv_start_date := p_start_date;
          ELSE
            p_inv_start_date := group_date_mon_rec.start_date;
          END IF;
          IF (group_date_mon_rec.end_date >= p_vr_term_date) THEN
            p_inv_end_date   := per_date_rec.end_date;
          ELSE
            p_inv_end_date   := group_date_mon_rec.end_date;
          END IF;

          p_invoice_date        := group_date_mon_rec.start_date;
          ------------------------------------------------------------
          -- calculation of schedule day taking the day of month or
          -- number of days after
          ------------------------------------------------------------
          IF (p_invg_day_of_month IS NOT NULL) THEN
            p_schedule_date:= (ADD_MONTHS(FIRST_DAY(p_inv_end_date),1)-1)+p_invg_day_of_month;
          ELSE
            p_schedule_date:= p_inv_end_date+nvl(p_invg_days_after,0);
          END IF;
          ------------------------------------------------------------
          -- takes care of the only 28 days for the schedule day
          ------------------------------------------------------------
          IF to_number(to_char(p_schedule_date,'dd')) in (29,30,31) THEN
            p_schedule_date:= (FIRST_DAY(p_schedule_date)+27);
          END IF;
          ------------------------------------------------------------
          --Eliminates all other records from the group_date_mon cursor
          --which do not belong to the period in period_dates cursor
          ------------------------------------------------------------

          IF ((group_date_mon_rec.start_date <= per_date_rec.end_date) AND
             (group_date_mon_rec.end_date >= p_start_date)) THEN

            FOR rec IN invoice_cur(p_inv_start_date, p_inv_end_date, p_period_id ) LOOP
              l_invoice_exists := 'Y';
            END LOOP;

            IF  l_invoice_exists = 'N' THEN
              ------------------------------------------------------------
              --call to update PN_VAR_GRP_DATES;
              ------------------------------------------------------------

              UPDATE PN_VAR_GRP_DATES
              SET inv_start_date    = p_inv_start_date,
                  inv_end_date      = p_inv_end_date,
                  invoice_date      = p_invoice_date,
                  inv_schedule_date = p_schedule_date
              WHERE grp_date_id in (SELECT grp_date_id
                                      FROM   pn_var_grp_dates
                                      WHERE grp_start_date <= p_inv_end_date
                                      AND   grp_end_date   >= p_inv_start_date
                                      AND   period_id       = p_period_id
                                      AND   var_rent_id     = p_var_rent_id)
              AND   period_id   = p_period_id
              AND   var_rent_id = p_var_rent_id;

            END IF;

          END IF;

        END LOOP;

      ELSIF (p_invg_freq_code = 3) THEN

        /* l_counter              := 0; */

        FOR group_date_qtr_rec IN group_date_qtr LOOP

          l_invoice_exists := 'N';
          /* l_counter           := group_date_qtr%ROWCOUNT; */

          IF group_date_qtr_rec.start_date < per_date_rec.start_date THEN
            p_inv_start_date := p_start_date;
          ELSE
            p_inv_start_date := group_date_qtr_rec.start_date;
          END IF;

          IF (group_date_qtr_rec.end_date >= p_vr_term_date) THEN
            p_inv_end_date   := per_date_rec.end_date;
          ELSE
            p_inv_end_date   := group_date_qtr_rec.end_date;
          END IF;

          p_invoice_date        := group_date_qtr_rec.start_date;
          ------------------------------------------------------------
          -- calculation of schedule day taking the day of month or
          -- number of days after
          ------------------------------------------------------------
          IF (p_invg_day_of_month IS NOT NULL) THEN
            p_schedule_date:= (ADD_MONTHS(FIRST_DAY(p_inv_end_date),1)-1)+p_invg_day_of_month;
          ELSE
            p_schedule_date:= p_inv_end_date+nvl(p_invg_days_after,0);
          END IF;
          ------------------------------------------------------------
          -- takes care of the only 28 days for the schedule day
          ------------------------------------------------------------
          IF to_number(to_char(p_schedule_date,'dd')) in (29,30,31) THEN
            p_schedule_date:= (FIRST_DAY(p_schedule_date)+27);
          END IF;
          ------------------------------------------------------------
          --Eliminates all other records from the group_date_qtr cursor
          --which do not belong to the period in period_dates cursor
          ------------------------------------------------------------
          IF ((group_date_qtr_rec.start_date <= per_date_rec.end_date) AND
             (group_date_qtr_rec.end_date >= p_start_date)) THEN

            FOR rec IN invoice_cur(p_inv_start_date, p_inv_end_date, p_period_id ) LOOP
              l_invoice_exists := 'Y';
            END LOOP;

            IF  l_invoice_exists = 'N' THEN
              ------------------------------------------------------------
              --call to update PN_VAR_GRP_DATES;
              ------------------------------------------------------------
              UPDATE PN_VAR_GRP_DATES
              SET inv_start_date    = p_inv_start_date,
                  inv_end_date      = p_inv_end_date,
                  invoice_date      = p_invoice_date,
                  inv_schedule_date = p_schedule_date
              WHERE grp_date_id in (SELECT grp_date_id
                                      FROM   pn_var_grp_dates
                                      WHERE grp_start_date <= p_inv_end_date
                                      AND   grp_end_date   >= p_inv_start_date
                                      AND   period_id       = p_period_id
                                      AND   var_rent_id     = p_var_rent_id)
              AND   period_id   = p_period_id
              AND   var_rent_id = p_var_rent_id;

            END IF;

          END IF;

        END LOOP;

      ELSIF (p_invg_freq_code = 6) THEN

        /* l_counter                := 0; */

        FOR group_date_sa_rec IN group_date_sa LOOP

          l_invoice_exists := 'N';
          /* l_counter            := group_date_sa%ROWCOUNT; */

          IF group_date_sa_rec.start_date < per_date_rec.start_date THEN
            p_inv_start_date := p_start_date;
          ELSE
            p_inv_start_date := group_date_sa_rec.start_date;
          END IF;
          IF (group_date_sa_rec.end_date >= p_end_date) THEN
            p_inv_end_date   := per_date_rec.end_date;
          ELSE
            p_inv_end_date   := group_date_sa_rec.end_date;
          END IF;

          p_invoice_date        := group_date_sa_rec.start_date;
          ------------------------------------------------------------
          -- calculation of schedule day taking the day of month or
          -- number of days after
          ------------------------------------------------------------
          IF (p_invg_day_of_month IS NOT NULL) THEN
            p_schedule_date:= (ADD_MONTHS(FIRST_DAY(p_inv_end_date),1)-1)+p_invg_day_of_month;
          ELSE
            p_schedule_date:= p_inv_end_date + NVL(p_invg_days_after,0);
          END IF;
          ------------------------------------------------------------
          -- takes care of the only 28 days for the schedule day
          ------------------------------------------------------------
          IF TO_NUMBER(TO_CHAR(p_schedule_date,'dd')) in (29,30,31) THEN
            p_schedule_date:= (FIRST_DAY(p_schedule_date)+27);
          END IF;
          ------------------------------------------------------------
          --Eliminates all other records from the group_date_sa cursor
          --which do not belong to the period in period_dates cursor
          ------------------------------------------------------------
          IF ((group_date_sa_rec.start_date <= per_date_rec.end_date) AND
             (group_date_sa_rec.end_date >= p_start_date)) THEN

            FOR rec IN invoice_cur(p_inv_start_date, p_inv_end_date, p_period_id ) LOOP
              l_invoice_exists := 'Y';
            END LOOP;

            IF  l_invoice_exists = 'N' THEN
              ------------------------------------------------------------
              --call to update PN_VAR_GRP_DATES;
              ------------------------------------------------------------
              UPDATE PN_VAR_GRP_DATES
              SET inv_start_date    = p_inv_start_date,
                  inv_end_date      = p_inv_end_date,
                  invoice_date      = p_invoice_date,
                  inv_schedule_date = p_schedule_date
              WHERE grp_date_id in (SELECT grp_date_id
                                      FROM   pn_var_grp_dates
                                      WHERE grp_start_date <= p_inv_end_date
                                      AND   grp_end_date   >= p_inv_start_date
                                      AND   period_id       = p_period_id
                                      AND   var_rent_id     = p_var_rent_id)
              AND   period_id   = p_period_id
              AND   var_rent_id = p_var_rent_id;

            END IF;

          END IF;

        END LOOP;

      ELSE

        /* l_counter      := 0; */
        FOR group_date_ann_rec IN group_date_ann LOOP

          /* l_counter           := group_date_ann%ROWCOUNT; */
          l_invoice_exists := 'N';

          IF group_date_ann_rec.start_date < per_date_rec.start_date THEN
            p_inv_start_date := p_start_date;
          ELSE
            p_inv_start_date := group_date_ann_rec.start_date;
          END IF;
          IF (group_date_ann_rec.end_date >= p_end_date) THEN
            p_inv_end_date   := per_date_rec.end_date;
          ELSE
            p_inv_end_date   := group_date_ann_rec.end_date;
          END IF;

          p_invoice_date     := group_date_ann_rec.start_date;
          ------------------------------------------------------------
          -- calculation of schedule day taking the day of month or
          -- number of days after
          ------------------------------------------------------------
          IF (p_invg_day_of_month IS NOT NULL) THEN
            p_schedule_date:= (ADD_MONTHS(FIRST_DAY(p_inv_end_date),1)-1)+p_invg_day_of_month;
          ELSE
            p_schedule_date:= p_inv_end_date+nvl(p_invg_days_after,0);
          END IF;
          ------------------------------------------------------------
          -- takes care of the only 28 days for the schedule day
          ------------------------------------------------------------
          IF to_number(to_char(p_schedule_date,'dd')) in (29,30,31) THEN
            p_schedule_date:= (FIRST_DAY(p_schedule_date)+27);
          END IF;
          ------------------------------------------------------------
          --Eliminates all other records from the group_date_ann cursor
          --which do not belong to the period in period_dates cursor
          ------------------------------------------------------------
          IF ((group_date_ann_rec.start_date <= per_date_rec.end_date) AND
             (group_date_ann_rec.end_date >= p_start_date)) THEN

            FOR rec IN invoice_cur(p_inv_start_date, p_inv_end_date, p_period_id ) LOOP
              l_invoice_exists := 'Y';
            END LOOP;

            IF  l_invoice_exists = 'N' THEN
              ------------------------------------------------------------
              --call to update PN_VAR_GRP_DATES;
              ------------------------------------------------------------

              UPDATE PN_VAR_GRP_DATES
              SET inv_start_date    = p_inv_start_date,
                  inv_end_date      = p_inv_end_date,
                  invoice_date      = p_invoice_date,
                  inv_schedule_date = p_schedule_date
              WHERE grp_date_id in (SELECT grp_date_id
                                      FROM   pn_var_grp_dates
                                      WHERE grp_start_date <= p_inv_end_date
                                      AND   grp_end_date   >= p_inv_start_date
                                      AND   period_id       = p_period_id
                                      AND   var_rent_id     = p_var_rent_id)
              AND   period_id   = p_period_id
              AND   var_rent_id = p_var_rent_id;

            END IF;

          END IF;

        END LOOP;

      END IF;

    END LOOP;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS (-)');

END CREATE_VAR_RENT_PERIODS;

/*=============================================================================+
--  NAME         : CREATE_VAR_RENT_PERIODS_NOCAL
--  DESCRIPTION  : Create variable rent periods recORd IN PN_VAR_PERIODS AND
--                 corresponding group date/invoice date records in the
--                 PN_VAR_GRP_DATES table for a variable rent recORd when a
--                 GL calendar is not specified in the VR agreement.
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN:
--                    p_var_rent_id
--                    p_cumulative_vol
--                    p_comm_date
--                    p_term_date
--                 OUT:
--
--  REFERENCE    : PN_COMMON.debug()
--  NOTES        : Create variable rent periods recORd IN PN_VAR_PERIODS AND
--                 corresponding group date/invoice date records in the
--                 PN_VAR_GRP_DATES table for a variable rent record for
--                 yearly VR periods depending on the year start date.
--                 Calls INSERT_PERIODS_ROW AND INSERT_GRP_DATE_ROW procedures
--  HISTORY      :
--  02-SEP-02  kkhegde  o Created
--  14-nov-02  kkhegde  o Replaced (substr(TO_CHAR(p_schedule_date),1,2)) with
--                        to_number(TO_CHAR(p_schedule_date,'dd') WHEREever it
--                        occurs.
--  31-MAY-05  Ajay Solanki
--     B88A - TEST - 37161: When using an Annual Reporting method, the
--     breakpoints for the last partial period are not being prorated.
--     We prorate for the first partial period, but use a annual
--     breakpoint in the last period.
--
--  26-OCT-05  piagrawa o Bug#4702709 - Passed org id in insert row handler.
--                        Pass org id to PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
--  05-jan-06  piagrawa o Bug #4630098 - added handling for passing correct
--                        proration factor to insert_grp_date_row.
--  11-JAN-07  Pseeram  o Added the call create_report_dates
--  21-MAR-07  Lbala    o Bug # 5937888 - added code to change reptg_due_date
+=============================================================================*/

PROCEDURE CREATE_VAR_RENT_PERIODS_NOCAL( p_var_rent_id    IN NUMBER,
                                         p_cumulative_vol IN VARCHAR2,
                                         p_yr_start_date  IN DATE) IS

TYPE period_rec is RECORD ( l_period_start_date       DATE,
                            l_period_end_date         DATE,
                            l_proration_factor        NUMBER,
                            l_period_id               NUMBER );

TYPE grp_date_rec is RECORD ( l_grp_start_date        DATE,
                              l_grp_end_date          DATE,
                              l_group_date            DATE,
                              l_reptg_due_date        DATE,
                              l_inv_start_date        DATE,
                              l_inv_end_date          DATE,
                              l_invoice_date          DATE,
                              l_inv_schedule_date     DATE,
                              l_proration_factor      NUMBER);

TYPE period_table_type is TABLE OF period_rec INDEX BY BINARY_INTEGER;
TYPE grp_date_table_type is TABLE OF grp_date_rec INDEX BY BINARY_INTEGER;

VR_periods    period_table_type;
VR_grp_dates  grp_date_table_type;

l_vr_comm_date                DATE;
l_vr_term_date                DATE;
l_total_per_proration_days    NUMBER;
l_period_freq_code            NUMBER;
l_reptg_freq_code             NUMBER;
l_reptg_day_of_month          NUMBER;
l_reptg_days_after            NUMBER;
l_invg_freq_code              NUMBER;
l_invg_day_of_month           NUMBER;
l_invg_days_after             NUMBER;

l_per_proration_factor        NUMBER;
l_grp_proration_factor        NUMBER;
-- variables for normal calendar year
l_period_start_date1          DATE;
l_period_end_date1            DATE;
l_grp_start_date1             DATE;
l_grp_end_date1               DATE;
l_inv_start_date1             DATE;
l_inv_end_date1               DATE := TO_DATE('01/01/0001','mm/dd/yyyy');
l_invoice_date1               DATE;
l_inv_schedule_date1          DATE;
-- variables for custom year
l_days_to_add                 NUMBER  := NULL;
-- counters
l_per_counter                 NUMBER  := 0;
l_grp_counter                 NUMBER  := 0;
l_inv_counter                 NUMBER  := 0;
l_grp_inv_counter             NUMBER  := 0;
-- for insert routines
l_rowId                 VARCHAR2(18)  := NULL;
l_periodId              NUMBER        := NULL;
l_grpDateId             NUMBER        := NULL;
l_periodNum             NUMBER        := NULL;
l_creation_date         DATE          := sysdate;
l_created_by            NUMBER        := NVL (fnd_profile.VALUE ('USER_ID'), 0);
l_partial_period        VARCHAR2(1)   := NULL;
l_period_exists         VARCHAR2(1)   := 'N';
l_proration_factor      NUMBER;

l_org_id    NUMBER;
l_add_flag  VARCHAR2(1) := 'N';
l_end_date  DATE := NULL;
l_status    pn_var_periods_all.status%TYPE;
l_dummy     VARCHAR2(1)   := NULL;
l_group_exists         VARCHAR2(1)   := 'N';
l_grp_date_id NUMBER;
l_grp_end_date DATE := NULL;

l_hyp_first_grp_st_dt DATE := NULL;
l_hyp_first_grp_ed_dt DATE := NULL;
l_hyp_last_grp_st_dt   DATE := NULL;
l_hyp_last_grp_ed_dt   DATE := NULL;

/* Fetches the group id which starts on a specified date for a VR agreement */
CURSOR group_cur (p_start_date DATE) IS
   SELECT grp_end_date, grp_date_id
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    grp_start_date  = p_start_date;

/* Fetches the period id which starts on a specified date for a VR agreement */
CURSOR period_cur (p_start_date DATE) IS
   SELECT period_id, end_date, status
   FROM   pn_var_periods_all
   WHERE  var_rent_id = p_var_rent_id
   AND    start_date  = p_start_date;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS_NOCAL (+)');
  put_log('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS_NOCAL (+)');

  SELECT  VR.commencement_date,
          VR.termination_date,
          DECODE(VR.proration_days,'999',365,VR.proration_days),
          DECODE(CAL.period_freq_code,'MON',1
                                     ,'QTR',3
                                     ,'SA' ,6
                                     ,'YR' ,12
                                     ,NULL),
          DECODE(CAL.reptg_freq_code,'MON',1
                                    ,'QTR',3
                                    ,'SA' ,6
                                    ,'YR' ,12
                                    ,NULL),
          CAL.reptg_day_of_month,
          CAL.reptg_days_after,
          DECODE(CAL.invg_freq_code,'MON',1
                                   ,'QTR',3
                                   ,'SA' ,6
                                   ,'YR' ,12
                                   ,NULL),
          CAL.invg_day_of_month,
          CAL.invg_days_after,
          VR.org_id
  INTO    l_vr_comm_date,
          l_vr_term_date,
          l_total_per_proration_days,
          l_period_freq_code,
          l_reptg_freq_code,
          l_reptg_day_of_month,
          l_reptg_days_after,
          l_invg_freq_code,
          l_invg_day_of_month,
          l_invg_days_after,
          l_org_id
  FROM   PN_VAR_RENTS_ALL VR, PN_VAR_RENT_DATES_ALL CAL
  WHERE  VR.var_rent_id  = p_var_rent_id
  AND    CAL.var_rent_id = VR.var_rent_id;

  -- generate periods

  l_period_start_date1 := p_yr_start_date;
  l_period_end_date1   := ADD_MONTHS(l_period_start_date1,12)-1;

  WHILE l_period_end_date1 < l_vr_comm_date LOOP
    l_period_start_date1 := l_period_end_date1 + 1;
    l_period_end_date1   := ADD_MONTHS(l_period_start_date1,12)-1;
  END LOOP;

  VR_periods(l_per_counter).l_period_start_date := l_vr_comm_date;
  VR_periods(l_per_counter).l_period_end_date   := l_period_end_date1;
  VR_periods(l_per_counter).l_proration_factor  := l_period_end_date1 - l_period_start_date1 + 1;
  l_per_proration_factor                        := VR_periods(l_per_counter).l_proration_factor;

  WHILE VR_periods(l_per_counter).l_period_end_date < l_vr_term_date LOOP

    l_per_counter := l_per_counter + 1;
    VR_periods(l_per_counter).l_period_start_date := VR_periods(l_per_counter-1).l_period_end_date + 1;
    VR_periods(l_per_counter).l_period_end_date   := ADD_MONTHS(VR_periods(l_per_counter).l_period_start_date,12) - 1;
    VR_periods(l_per_counter).l_proration_factor  := VR_periods(l_per_counter).l_period_end_date
                                                       - VR_periods(l_per_counter).l_period_start_date + 1;
  END LOOP;

  VR_periods(l_per_counter).l_period_end_date := l_vr_term_date;

  -- insert period rows

  FOR i IN 0..VR_periods.COUNT-1 LOOP

    l_period_exists := 'N';

    /* Check if the period in PL/SQL table with a specified start date
      already exists in database */
    FOR period_rec IN period_cur(vr_periods(i).l_period_start_date)  LOOP
      l_periodId := period_rec.period_id;
      l_end_date := period_rec.end_date;
      l_status   := period_rec.status;
      l_period_exists := 'Y';
      pnp_debug_pkg.debug(' period exists ...'||l_periodId);
      pnp_debug_pkg.debug('');
    END LOOP;

    IF l_period_exists = 'N' THEN  /* Insert the period if it does not exist */

      IF (vr_periods(i).l_period_end_date - vr_periods(i).l_period_start_date+1) >=365 THEN
        l_partial_period := 'N';
      ELSE
        l_partial_period := 'Y';
      END IF;

      pnp_debug_pkg.debug('New Period Start Date:'||vr_periods(i).l_period_start_date);
      pnp_debug_pkg.debug('New Period End Date:'||vr_periods(i).l_period_end_date);
      pnp_debug_pkg.debug('partial period ...'||l_partial_period);

      PN_VAR_RENT_PKG.INSERT_PERIODS_ROW
         ( X_ROWID              => l_rowId,
           X_PERIOD_ID          => VR_periods(i).l_period_id,
           X_PERIOD_NUM         => l_periodNum,
           X_VAR_RENT_ID        => p_var_rent_id,
           X_START_DATE         => VR_periods(i).l_period_start_date,
           X_END_DATE           => VR_periods(i).l_period_end_date,
           X_PRORATION_FACTOR   => VR_periods(i).l_proration_factor,
           X_PARTIAL_PERIOD     => l_partial_period,
           X_ATTRIBUTE_CATEGORY => NULL,
           X_ATTRIBUTE1         => NULL,
           X_ATTRIBUTE2         => NULL,
           X_ATTRIBUTE3         => NULL,
           X_ATTRIBUTE4         => NULL,
           X_ATTRIBUTE5         => NULL,
           X_ATTRIBUTE6         => NULL,
           X_ATTRIBUTE7         => NULL,
           X_ATTRIBUTE8         => NULL,
           X_ATTRIBUTE9         => NULL,
           X_ATTRIBUTE10        => NULL,
           X_ATTRIBUTE11        => NULL,
           X_ATTRIBUTE12        => NULL,
           X_ATTRIBUTE13        => NULL,
           X_ATTRIBUTE14        => NULL,
           X_ATTRIBUTE15        => NULL,
           X_CREATION_DATE      => l_creation_date,
           X_CREATED_BY         => l_created_by,
           X_LAST_UPDATE_DATE   => l_creation_date,
           X_LAST_UPDATED_BY    => l_created_by,
           X_LAST_UPDATE_LOGIN  => l_created_by
      );

      pnp_debug_pkg.debug('period inserted is ...'||VR_periods(i).l_period_id);
      l_rowId     := NULL;
      l_periodNum := NULL;

    ELSE /* period exists in the database */

      pnp_debug_pkg.debug('New Period Start Date:'||vr_periods(i).l_period_start_date);
      pnp_debug_pkg.debug('New Period End Date:'||vr_periods(i).l_period_end_date);
      pnp_debug_pkg.debug('l_end_date:'||l_end_date);

      VR_periods(i).l_period_id := l_periodId;

      /* Check if the period in the database is a partial period */
      IF vr_periods(i).l_period_end_date = l_end_date THEN

        pnp_debug_pkg.debug('period end date is equsal to period in data base ..');

        /* Make the period as active if it is inactive */
        IF  l_status = pn_var_rent_pkg.status THEN

          pnp_debug_pkg.debug('period is inactive ..'||l_periodId);

          UPDATE pn_var_periods_all
          SET status = NULL
          WHERE period_id = l_periodId;

        END IF;

      ELSIF  vr_periods(i).l_period_end_date <> l_end_date THEN

        pnp_debug_pkg.debug('Need to update the period end date '||l_periodId);

        IF (vr_periods(i).l_period_end_date
            - vr_periods(i).l_period_start_date) + 1 >= 365 THEN

          l_partial_period := 'N';
        ELSE

          l_partial_period := 'Y';
        END IF;

        /* Updte the end date and partial flag for the period */
        UPDATE pn_var_periods_all
        SET
        end_date = vr_periods(i).l_period_end_date,
        partial_period = l_partial_period,
        status = NULL
        WHERE period_id = l_periodId;

      END IF;

    END IF;

  END LOOP;

  -- generate group dates, invoice dates

  -- first generate group dates

  l_grp_start_date1 := l_period_start_date1;
  l_grp_end_date1   := ADD_MONTHS(l_grp_start_date1,l_reptg_freq_code)-1;

  WHILE l_grp_end_date1 < l_vr_comm_date LOOP
    l_grp_start_date1 := l_grp_end_date1 + 1;
    l_grp_end_date1   := ADD_MONTHS(l_grp_start_date1,l_reptg_freq_code)-1;
  END LOOP;

  VR_grp_dates(l_grp_counter).l_grp_start_date := l_vr_comm_date;
  VR_grp_dates(l_grp_counter).l_grp_end_date   := l_grp_end_date1;
  VR_grp_dates(l_grp_counter).l_group_date     := l_grp_start_date1;
  VR_grp_dates(l_grp_counter).l_reptg_due_date
     := NVL( ((ADD_MONTHS(FIRST_DAY(VR_grp_dates(l_grp_counter).l_grp_end_date),1)-1) + l_reptg_day_of_month),
             (VR_grp_dates(l_grp_counter).l_grp_end_date + NVL(l_reptg_days_after,0)) );
  VR_grp_dates(l_grp_counter).l_proration_factor
     := ((l_grp_end_date1-l_vr_comm_date)+1)/((l_grp_end_date1-l_grp_start_date1)+1);

  l_hyp_first_grp_st_dt := l_grp_start_date1;
  l_hyp_first_grp_ed_dt := l_grp_end_date1;

  WHILE VR_grp_dates(l_grp_counter).l_grp_end_date < l_vr_term_date LOOP
    l_grp_counter := l_grp_counter + 1;
    VR_grp_dates(l_grp_counter).l_grp_start_date := VR_grp_dates(l_grp_counter-1).l_grp_end_date + 1;
    VR_grp_dates(l_grp_counter).l_grp_end_date   := ADD_MONTHS(VR_grp_dates(l_grp_counter).l_grp_start_date,
                                                               l_reptg_freq_code) - 1;
    VR_grp_dates(l_grp_counter).l_group_date     := VR_grp_dates(l_grp_counter).l_grp_start_date;
    VR_grp_dates(l_grp_counter).l_reptg_due_date :=
      NVL( ((ADD_MONTHS(FIRST_DAY(VR_grp_dates(l_grp_counter).l_grp_end_date),1)-1) + l_reptg_day_of_month),
           (VR_grp_dates(l_grp_counter).l_grp_end_date + nvl(l_reptg_days_after,0)) );
    VR_grp_dates(l_grp_counter).l_proration_factor := 1;
  END LOOP;

  l_hyp_last_grp_st_dt  :=  vr_grp_dates(l_grp_counter).l_grp_start_date;
  l_hyp_last_grp_ed_dt  :=  vr_grp_dates(l_grp_counter).l_grp_end_date;

  VR_grp_dates(l_grp_counter).l_grp_end_date   := l_vr_term_date;

  -- now, generate invoice dates

  WHILE l_inv_end_date1 < l_vr_term_date LOOP

    IF l_inv_counter = 0 THEN
      l_inv_start_date1 := l_period_start_date1;
      l_inv_end_date1   := ADD_MONTHS(l_inv_start_date1,l_invg_freq_code)-1;

      WHILE l_inv_end_date1 < l_vr_comm_date LOOP
        l_inv_start_date1 := l_inv_end_date1 + 1;
        l_inv_end_date1   := ADD_MONTHS(l_inv_start_date1,l_invg_freq_code)-1;
      END LOOP;

      l_invoice_date1      := l_inv_start_date1;
      l_inv_start_date1    := l_vr_comm_date;
    ELSE
      l_inv_start_date1 := l_inv_end_date1 + 1;
      l_inv_end_date1   := ADD_MONTHS(l_inv_start_date1,l_invg_freq_code)-1;
      l_invoice_date1   := l_inv_start_date1;
    END IF;

    l_inv_schedule_date1 :=
      NVL( ((ADD_MONTHS(FIRST_DAY(l_inv_end_date1),1)-1) + l_invg_day_of_month),
              (l_inv_end_date1 + nvl(l_invg_days_after,0)) );

    IF l_inv_end_date1 > l_vr_term_date THEN
      l_inv_end_date1 := l_vr_term_date;
    END IF;
    ------------------------------------------------------------
    -- takes care of the only 28 days for the schedule day
    ------------------------------------------------------------
    IF TO_NUMBER(TO_CHAR(l_inv_schedule_date1,'dd')) in (29,30,31) THEN
      l_inv_schedule_date1:= (FIRST_DAY(l_inv_schedule_date1)+27);
    END IF;
    ------------------------------------------------------------

    FOR i IN l_grp_inv_counter..VR_grp_dates.COUNT-1 LOOP
      EXIT WHEN VR_grp_dates(i).l_grp_start_date > l_inv_end_date1;
      VR_grp_dates(i).l_inv_start_date := l_inv_start_date1;
      VR_grp_dates(i).l_inv_end_date := l_inv_end_date1;
      VR_grp_dates(i).l_invoice_date := l_invoice_date1;
      VR_grp_dates(i).l_inv_schedule_date := l_inv_schedule_date1;
      l_grp_inv_counter := l_grp_inv_counter + 1;
    END LOOP;

    l_inv_counter := l_inv_counter + 1;

  END LOOP;

  -- now, insert the group dates and the invoice dates....

  l_grp_counter := 0;

  FOR i IN 0..VR_periods.COUNT - 1 LOOP

    FOR j IN l_grp_counter..(VR_grp_dates.COUNT - 1) LOOP

      l_group_exists := 'N';

      pnp_debug_pkg.debug(' group start date ...'||VR_grp_dates(j).l_grp_start_date);
      pnp_debug_pkg.debug(' group end date ...'||VR_periods(i).l_period_end_date);

      EXIT WHEN VR_grp_dates(j).l_grp_start_date > VR_periods(i).l_period_end_date;

      /* Check if the group in PL/SQL table with a specified start date
         already exists in database */
      FOR group_rec IN group_cur(VR_grp_dates(j).l_grp_start_date)  LOOP
        l_grp_date_id  := group_rec.grp_date_id;
        l_grp_end_date := group_rec.grp_end_date;
        l_group_exists := 'Y';
      END LOOP;

      IF l_group_exists = 'N' THEN

        /* group does not exist in the database and needs to be added */
        pnp_debug_pkg.debug (' Group does not exist - to insert group ');

        /*l_proration_Factor
        := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) + 1 )
           / ((LAST_DAY(ADD_MONTHS(LAST_DAY(vr_grp_dates(j).l_group_date),l_reptg_freq_code-1))
          - vr_grp_dates(j).l_group_date)+1);*/

        IF VR_grp_dates(j).l_grp_start_date
           BETWEEN l_hyp_first_grp_st_dt AND l_hyp_first_grp_ed_dt
        THEN

          l_proration_Factor
          := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) + 1)
             / ((l_hyp_first_grp_ed_dt - l_hyp_first_grp_st_dt) + 1);

        ELSIF VR_grp_dates(j).l_grp_end_date
              BETWEEN l_hyp_last_grp_st_dt AND l_hyp_last_grp_ed_dt
        THEN

          l_proration_factor
          := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) + 1 )
             / ((l_hyp_last_grp_ed_dt - l_hyp_last_grp_st_dt) + 1);

        ELSE

          l_proration_Factor := 1;

        END IF;

        PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW
          ( X_ROWID               => l_rowId,
            X_GRP_DATE_ID         => l_grpDateId,
            X_VAR_RENT_ID         => p_var_rent_id,
            X_PERIOD_ID           => VR_periods(i).l_period_id,
            X_GRP_START_DATE      => VR_grp_dates(j).l_grp_start_date,
            X_GRP_END_DATE        => VR_grp_dates(j).l_grp_end_date,
            X_GROUP_DATE          => VR_grp_dates(j).l_group_date,
            X_REPTG_DUE_DATE      => VR_grp_dates(j).l_reptg_due_date,
            X_INV_START_DATE      => VR_grp_dates(j).l_inv_start_date,
            X_INV_END_DATE        => VR_grp_dates(j).l_inv_end_date,
            X_INVOICE_DATE        => VR_grp_dates(j).l_invoice_date,
            X_INV_SCHEDULE_DATE   => VR_grp_dates(j).l_inv_schedule_date,
            X_PRORATION_FACTOR    => l_proration_factor,
            X_ACTUAL_EXP_CODE     => 'N',
            X_FORECASTED_EXP_CODE => 'N',
            X_VARIANCE_EXP_CODE   => 'N',
            X_CREATION_DATE       => l_creation_date,
            X_CREATED_BY          => l_created_by,
            X_LAST_UPDATE_DATE    => l_creation_date,
            X_LAST_UPDATED_BY     => l_created_by,
            X_LAST_UPDATE_LOGIN   => l_created_by
          );

        pnp_debug_pkg.debug ('group dte id of group added ....'||l_grpDateId);
        l_rowId     := NULL;
        l_grpDateId := NULL;

      ELSE

        pnp_debug_pkg.debug (' group exists - update it ');
        /* Check if the group in the database is a partial or if the new group is partial */

        IF VR_grp_dates(j).l_grp_end_date <> l_grp_end_date THEN

          /*l_proration_Factor := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) +1 )/
             ((LAST_DAY(ADD_MONTHS(LAST_DAY(vr_grp_dates(j).l_group_date),l_reptg_freq_code-1))
             - vr_grp_dates(j).l_group_date)+1);*/

          IF VR_grp_dates(j).l_grp_start_date
             BETWEEN l_hyp_first_grp_st_dt AND l_hyp_first_grp_ed_dt
          THEN

            l_proration_Factor
            := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) + 1)
               / ((l_hyp_first_grp_ed_dt - l_hyp_first_grp_st_dt) + 1);

          ELSIF VR_grp_dates(j).l_grp_end_date
                BETWEEN l_hyp_last_grp_st_dt AND l_hyp_last_grp_ed_dt
          THEN

            l_proration_factor
            := ((vr_grp_dates(j).l_grp_end_date - vr_grp_dates(j).l_grp_start_date) + 1 )
               / ((l_hyp_last_grp_ed_dt - l_hyp_last_grp_st_dt) + 1);

          ELSE

            l_proration_Factor := 1;

          END IF;

          pnp_debug_pkg.debug ('updating end date of group '||VR_grp_dates(j).l_grp_end_date);
          pnp_debug_pkg.debug ('updating proration factor as '||l_proration_Factor);
          pnp_debug_pkg.debug ('updating due date of group '||VR_grp_dates(j).l_reptg_due_date);
          /* Updte the end date and proration factor for the group */

          UPDATE pn_var_grp_dates_all
          SET grp_end_date = VR_grp_dates(j).l_grp_end_date,
              proration_Factor = round(l_proration_Factor,10),
              reptg_due_date = VR_grp_dates(j).l_reptg_due_date --Bug # 5937888
          WHERE grp_date_id = l_grp_date_id;

        END IF;

      END IF;

      l_grp_counter := l_grp_counter + 1;

    END LOOP;

  END LOOP;

  PN_VAR_RENT_PKG.delete_report_date_row(p_var_rent_id, NULL);
  PN_VAR_RENT_PKG.create_report_dates (p_var_rent_id);

  put_log('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS_NOCAL (-)');
  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CREATE_VAR_RENT_PERIODS_NOCAL (-)');

END CREATE_VAR_RENT_PERIODS_NOCAL;

/*=============================================================================+
| PROCEDURE
|    DELETE_VAR_RENT_PERIODS
|
| DESCRIPTION
|    Delete variable rent periods record in PN_VAR_PERIODS, corresponding
|    group date/invoice date records in the PN_VAR_GRP_DATES table,
|    corresponding line items in the PN_VAR_LINES table
|    for a variable rent record
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id
|                    p_term_date
|
|              OUT:
|
| RETURNS : None
|
| NOTES   : Delete variable rent periods record in PN_VAR_PERIODS,
|           corresponding group date/invoice date records in the
|           PN_VAR_GRP_DATES table, corresponding line items in the
|           PN_VAR_LINES table for a variable rent record
|           Calls DELETE_PERIODS_ROW, DELETE_GRP_DATE_ROW,
|           DELETE_VAR_RENT_LINES procedures
|
| MODIFICATION HISTORY
|
| 03-SEP-01  Daniel   o Created
| 27-DEC-01  Daniel   o included parameter p_term_date for contraction.
| 14-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_RENT_SUMM with _ALL tbl.
| 11-JAN-07  Pseeram  o Added the call delete_report_date_row to delete
|                       report dates records after undo periods.
| 09-FEB-07  Lokesh   o Bug # 5874461, Added NVL for export_to_ar_flag
+=============================================================================*/
PROCEDURE DELETE_VAR_RENT_PERIODS(p_var_rent_id IN NUMBER,
                                  p_term_date   IN DATE ) IS

l_lines_exist           NUMBER  := NULL;
l_constr_exist          NUMBER  := NULL;
l_date                  DATE;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_PERIODS (+)');

  l_lines_exist := PN_VAR_RENT_PKG.find_if_lines_exist(p_var_rent_id, NULL, l_date);

  l_constr_exist:= PN_VAR_RENT_PKG.find_if_constr_exist(p_var_rent_id, l_date);

  l_date        := NVL(p_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

  -- Added by Sathesh K 15-APR-2005 to delete schedules and items records
  -- Mac Trac Issue M30106

  DELETE FROM pn_payment_schedules_all
  WHERE  payment_schedule_id IN
         (SELECT payment_schedule_id
          FROM   pn_payment_items_all
          WHERE  NVL(export_to_ar_flag,'N') <>'Y'
          AND    payment_term_id IN
                 (SELECT payment_term_id
                  FROM   pn_payment_terms
                  WHERE  VAR_RENT_INV_ID IN
                         (SELECT var_rent_inv_id
                          FROM   pn_var_rent_inv_all
                          WHERE  var_rent_id = p_var_rent_id
                         )
                 )
         )
  AND payment_status_lookup_code <>'APPROVED';

  DELETE FROM pn_payment_items_all
  WHERE  payment_term_id IN
         (SELECT payment_term_id
          FROM   pn_payment_terms_all
          WHERE  var_rent_inv_id IN
                 (SELECT var_rent_inv_id
                  FROM  pn_var_rent_inv_all
                  WHERE var_rent_id = p_var_rent_id
                 )
         )
  AND NVL(export_to_ar_flag,'N') <>'Y'   ;

  ---Mac Trac Issue M30106 ends here -----

  DELETE FROM  pn_var_rent_summ
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM pn_payment_terms
  WHERE var_rent_inv_id IN
        (SELECT var_rent_inv_id
         FROM   pn_var_rent_inv_all
         WHERE  var_rent_id = p_var_rent_id)
  AND   NOT EXISTS
        (SELECT 1
         FROM   pn_payment_items
         WHERE  export_to_ar_flag ='Y'
         AND    payment_term_id IN
                (SELECT payment_term_id
                 FROM pn_payment_terms
                 WHERE VAR_RENT_INV_ID IN
                       (SELECT VAR_RENT_INV_ID
                        FROM   PN_VAR_RENT_INV_ALL
                        WHERE VAR_RENT_ID = p_var_rent_id
                       )
                )
        );

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM  pn_var_rent_inv
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  pn_var_rent_pkg.delete_report_date_row(p_var_rent_id,l_date);

  pn_var_rent_pkg.delete_grp_date_row(p_var_rent_id,l_date);

  IF l_lines_exist IS NOT NULL THEN
    pn_var_rent_pkg.delete_var_rent_lines(p_var_rent_id,l_date);
  END IF;

  IF l_constr_exist IS NOT NULL THEN
    pn_var_rent_pkg.delete_var_rent_constr(p_var_rent_id,l_date);
  END IF;

  pn_var_rent_pkg.delete_periods_row(p_var_rent_id,l_date);

  /*DELETE FROM pn_var_transactions_all
  WHERE var_rent_id = p_var_rent_id;*/

  DELETE FROM pn_var_abat_defaults_all
  where var_rent_id = p_var_rent_id;

  DELETE FROM pn_var_abatements_all abat
  where abat.var_rent_id=p_var_rent_id;

  DELETE FROM pn_var_bkdt_defaults_all
  WHERE var_rent_id = p_var_rent_id;

  DELETE pn_var_bkhd_defaults_all
  WHERE var_rent_id = p_var_rent_id;

  DELETE pn_var_line_defaults_all
  WHERE var_rent_id = p_var_rent_id;

  DELETE pn_var_constr_defaults_all
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_PERIODS (-)');

END DELETE_VAR_RENT_PERIODS;

/*=============================================================================+
| PROCEDURE
|    UPDATE_VAR_RENT_PERIODS
|
| DESCRIPTION
| Update variable rent periods record in PN_VAR_PERIODS, corresponding
| group date/invoice date records in the PN_VAR_GRP_DATES table
| for a variable rent record contraction
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id
|                    p_term_date
|
|              OUT:
|
| RETURNS : None
|
| NOTES   : Update variable rent periods record in PN_VAR_PERIODS, corresponding
|           group date/invoice date records in the PN_VAR_GRP_DATES table
|           for a variable rent record contraction
|
| MODIFICATION HISTORY
|
| 29-DEC-01  Daniel   o Created
| 04-JUL-05  hareesha o Bug 4284035 - Replaced PN_VAR_PERIODS with _ALL table
+=============================================================================*/
PROCEDURE UPDATE_VAR_RENT_PERIODS(p_var_rent_id    IN NUMBER,
                                  p_term_date      IN DATE ) IS

p_last_update_date      DATE        := SYSDATE;
p_last_updated_by       NUMBER      := NVL (fnd_profile.VALUE ('USER_ID'), 0);
p_per_start_date        DATE        := TO_DATE('01/01/1776','mm/dd/yyyy');
p_per_end_date          DATE        := TO_DATE('01/01/1776','mm/dd/yyyy');
p_grp_start_date        DATE        := TO_DATE('01/01/1776','mm/dd/yyyy');
p_grp_end_date          DATE        := TO_DATE('01/01/1776','mm/dd/yyyy');
p_reptg_freq_code       NUMBER      := NULL;
tot_per_proration_days  NUMBER      := 0;
per_proration_days      NUMBER      := 0;
tot_grp_proration_days  NUMBER      := 0;
grp_proration_days      NUMBER      := 0;
p_proration_factor      NUMBER      := 0;
p_cumulative_vol        VARCHAR2(1);

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.UPDATE_VAR_RENT_PERIODS (+)');

  -- Get dates/info, GL calendar used from Variable Rent record

  SELECT DECODE(cal.reptg_freq_code,'MON', 1,
                                    'QTR', 3,
                                    'SA', 6,
                                    'YR', 12,
                                    null)
  INTO   p_reptg_freq_code
  FROM   PN_VAR_RENT_DATES_ALL cal
  WHERE  cal.var_rent_id = p_var_rent_id;

  -- Get period start date for the last period which has to be
  -- updated with the new proration factor after lease contraction

  SELECT per.start_date
  INTO   p_per_start_date
  FROM   PN_VAR_PERIODS_ALL per
  WHERE  per.var_rent_id  =  p_var_rent_id
  AND    per.start_date   <= p_term_date
  AND    per.end_date     >= p_term_date
  AND    rownum           <  2;

  -- Get proration days info from the main VR record

  SELECT decode(proration_days,999,365,proration_days)
  INTO   tot_per_proration_days
  FROM   pn_var_rents_ALL
  WHERE  var_rent_id = p_var_rent_id;

  -- Get group start date for the last group which has to be
  -- updated with the new proration factor after lease contraction

  SELECT grp.grp_start_date
  INTO   p_grp_start_date
  FROM   pn_var_grp_dates_all grp
  WHERE  grp.var_rent_id    =  p_var_rent_id
  AND    grp.grp_start_date <= p_term_date
  AND    grp.grp_end_date   >= p_term_date
  AND    rownum             <  2;

  per_proration_days := (p_term_date-p_per_start_date)+1;
  p_proration_factor := ROUND((per_proration_days/tot_per_proration_days),2);
  IF p_proration_factor > 1 THEN
    p_proration_factor := 1;
  END IF;

  --call to update PN_VAR_PERIODS;
  UPDATE pn_var_periods_all
  SET    end_date          = p_term_date,
         proration_factor  = p_proration_factor,
         last_update_date  = p_last_update_date,
         last_updated_by   = p_last_updated_by,
         last_update_login = p_last_updated_by
  WHERE  var_rent_id       =  p_var_rent_id
  AND    start_date        <= p_term_date
  AND    end_date          >= p_term_date
  AND    rownum            <  2;

  IF p_cumulative_vol = 'N' THEN

    IF (p_reptg_freq_code = 1) THEN
      tot_grp_proration_days := 30;
    ELSIF (p_reptg_freq_code = 3) THEN
      tot_grp_proration_days := 90;
    ELSIF (p_reptg_freq_code = 6) THEN
      tot_grp_proration_days := 180;
    ELSE
      tot_grp_proration_days := 365;
    END IF;

    grp_proration_days  := ( p_term_date - p_grp_start_date) + 1;

    p_proration_factor  := ROUND((grp_proration_days/tot_grp_proration_days),2);
    IF p_proration_factor > 1 THEN
       p_proration_factor := 1;
    END IF;

  END IF;

  --call to update PN_VAR_GRP_DATES;

  UPDATE pn_var_grp_dates_all
  SET    grp_end_date      = p_term_date,
         proration_factor  = round(p_proration_factor,10),
         last_update_date  = p_last_update_date,
         last_updated_by   = p_last_updated_by,
         last_update_login = p_last_updated_by
  WHERE  var_rent_id       =  p_var_rent_id
  AND    grp_start_date    <= p_term_date
  AND    grp_end_date      >= p_term_date
  AND    rownum            <  2;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.UPDATE_VAR_RENT_PERIODS (-)');

END UPDATE_VAR_RENT_PERIODS;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_RENT_CONSTR
 |
 | DESCRIPTION
 |    Delete variable rent constraints from the PN_VAR_CONSTRAINTS table for each period
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |              PN_VAR_CONSTRAINTS_PKG.DELETE_ROW
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_term_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete variable rent constraints from the PN_VAR_CONSTRAINTS table for each period
 |
 | MODIFICATION HISTORY
 |
 |     03-DEC-2001  Daniel Thota  o Created
 |     27-DEC-2001  Daniel Thota  o Included parameter p_term_date for contraction.
 +===========================================================================*/

PROCEDURE DELETE_VAR_RENT_CONSTR(p_var_rent_id IN NUMBER,
                                 p_term_date   IN DATE ) IS

l_counter       NUMBER := 0;
l_date          DATE   := nvl(p_term_date,(to_date('01/01/1776','mm/dd/yyyy')));

CURSOR c1 IS
  SELECT constraint_id
  FROM   PN_VAR_CONSTRAINTS_ALL
  WHERE  period_id IN (SELECT period_id
                       FROM   PN_VAR_PERIODS_ALL
                       WHERE  var_rent_id = p_var_rent_id
                       AND    start_date  > l_date
                       AND    end_date    > l_date);

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_CONSTR (+)');

  FOR constr_rec IN c1 LOOP

    PN_VAR_CONSTRAINTS_PKG.DELETE_ROW(constr_rec.constraint_id);

    l_counter := l_counter + 1;

    IF l_counter = 1000 THEN
      COMMIT;
      l_counter := 1;
    END IF;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_CONSTR (-)');

END DELETE_VAR_RENT_CONSTR;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_RENT_LINES
 |
 | DESCRIPTION
 |    Delete variable rent lines record in PN_VAR_LINES and associated
 |    volume history records in the PN_VAR_VOL_HIST table for a
 |    variable rent record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |              PN_VAR_LINES_PKG.DELETE_ROW
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_term_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete variable rent lines record in PN_VAR_LINES and associated
 |              volume history records in the PN_VAR_VOL_HIST table for a
 |              variable rent record
 |
 | MODIFICATION HISTORY
 |
 | 15-OCT-2001  Daniel Thota  o Created
 | 27-DEC-2001  Daniel Thota  o Included parameter p_term_date for contraction.
 | 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_lines with _ALL table.
 +===========================================================================*/

PROCEDURE DELETE_VAR_RENT_LINES(p_var_rent_id IN NUMBER,
                                p_term_date   IN DATE ) IS

l_counter       NUMBER := 0;
l_bkptshd_exist NUMBER := NULL;
l_volhist_exist NUMBER := NULL;
l_deduct_exist  NUMBER := NULL;
l_date          DATE   := NVL(p_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

CURSOR c1 is
  SELECT line_item_id
  FROM   pn_var_lines
  WHERE  period_id IN (SELECT period_id
                       FROM   pn_var_periods_ALL
                       WHERE  var_rent_id = p_var_rent_id
                       AND    start_date  > l_date
                       AND    end_date    > l_date);

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_LINES (+)');

  FOR lines_rec IN c1 LOOP

    l_bkptshd_exist := PN_VAR_RENT_PKG.find_if_bkptshd_exist(lines_rec.line_item_id);
    -------------------------------------------------------------------------
    -- First delete breakpoints associated with each line associated with each
    -- period for this variable rent record
    -------------------------------------------------------------------------
    IF l_bkptshd_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_HEAD(lines_rec.line_item_id);
    END IF;

    l_volhist_exist := PN_VAR_RENT_PKG.find_if_volhist_exist(lines_rec.line_item_id);
    -------------------------------------------------------------------------
    -- First delete volume history associated with each line associated with each
    -- period for this variable rent record
    -------------------------------------------------------------------------
    IF l_volhist_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_VOL_HIST(lines_rec.line_item_id);
    END IF;

    l_deduct_exist := PN_VAR_RENT_PKG.find_if_deduct_exist(lines_rec.line_item_id);
    -------------------------------------------------------------------------
    -- First delete deductions associated with each line associated with each
    -- period for this variable rent record
    -------------------------------------------------------------------------
    IF l_deduct_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_RENT_DEDUCT(lines_rec.line_item_id);
    END IF;
    -------------------------------------------------------------------------
    -- Delete lines associated with each period for this variable rent record
    -------------------------------------------------------------------------
    PN_VAR_LINES_PKG.DELETE_ROW(lines_rec.line_item_id);

    l_counter := l_counter + 1;

    IF l_counter = 1000 THEN
      COMMIT;
      l_counter := 1;
    END IF;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_LINES (-)');

END DELETE_VAR_RENT_LINES;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_RENT_DEDUCT
 |
 | DESCRIPTION
 |    Delete variable rent deductions from the PN_VAR_DEDUCTIONS table for each line
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |              PN_VAR_DEDUCTIONS_PKG.DELETE_ROW
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete variable rent deductions from the PN_VAR_DEDUCTIONS table for each line
 |
 | MODIFICATION HISTORY
 |
 |     03-DEC-2001  Daniel Thota  o Created
 +===========================================================================*/

PROCEDURE DELETE_VAR_RENT_DEDUCT(p_line_item_id IN NUMBER) IS

l_counter NUMBER := 0;

CURSOR c1 is
  SELECT deduction_id
  FROM   PN_VAR_DEDUCTIONS_ALL
  WHERE  line_item_id = p_line_item_id;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_DEDUCT (+)');

  FOR deduct_rec IN c1 LOOP

    PN_VAR_DEDUCTIONS_PKG.DELETE_ROW(deduct_rec.deduction_id);

    l_counter := l_counter + 1;

    IF l_counter = 1000 THEN
      COMMIT;
      l_counter := 1;
    END IF;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_DEDUCT (-)');

END DELETE_VAR_RENT_DEDUCT;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_VOL_HIST
 |
 | DESCRIPTION
 |    Delete variable rent lines
 |    volume history records in the PN_VAR_VOL_HIST table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |              PN_VAR_LINES_PKG.DELETE_ROW
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete variable rent lines
 |              volume history records in the PN_VAR_VOL_HIST table
 |
 | MODIFICATION HISTORY
 |
 |     30-NOV-2001  Daniel Thota  o Created
 +===========================================================================*/

PROCEDURE DELETE_VAR_VOL_HIST(p_line_item_id IN NUMBER) IS

l_counter NUMBER := 0;

CURSOR c1 IS
SELECT vol_hist_id
FROM   PN_VAR_VOL_HIST_ALL
WHERE  line_item_id = p_line_item_id;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_VOL_HIST (+)');

  FOR vol_hist_rec IN c1 LOOP

    PN_VAR_VOL_HIST_PKG.DELETE_ROW(vol_hist_rec.vol_hist_id);

    l_counter := l_counter + 1;

    IF l_counter = 1000 THEN
      COMMIT;
      l_counter := 1;
    END IF;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_VOL_HIST (-)');

END DELETE_VAR_VOL_HIST;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_BKPTS_HEAD
 |
 | DESCRIPTION
 |    Delete breakpoint details records in PN_VAR_BKPTS_DET for a
 |    line item record.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |              PN_VAR_LINES_PKG.DELETE_ROW
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Delete breakpoint details records in PN_VAR_BKPTS_DET for a
 |              line item record.
 |
 | MODIFICATION HISTORY
 |
 | 17-NOV-2001  Daniel Thota  o Created
 | 20-JAN-06  Pikhar  o Used cursor to delete Breakpoint Headers
 +===========================================================================*/

PROCEDURE DELETE_VAR_BKPTS_HEAD(p_line_item_id   IN NUMBER) IS

l_bkpt_header_id  NUMBER := 0;
l_bkptsdet_exISt  NUMBER := NULL;

CURSOR c2 IS
   SELECT bkpt_header_id
   FROM   pn_var_bkpts_head_all
   WHERE  line_item_id = p_line_item_id;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_HEAD (+)');

  FOR head_rec IN c2 LOOP

    l_bkptsdet_exist := PN_VAR_RENT_PKG.find_if_bkptsdet_exist(head_rec.bkpt_header_id);
    -------------------------------------------------------------------------
    -- First DELETE breakpoINt details ASsociated with each breakpoINt header
    -------------------------------------------------------------------------
    IF l_bkptsdet_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_DET(head_rec.bkpt_header_id);
    END IF;
    -----------------------------------------------------
    -- DELETE breakpoINt header ASsociated with each lINe
    -----------------------------------------------------
     PN_VAR_BKPTS_HEAD_PKG.DELETE_ROW(head_rec.bkpt_header_id);

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_HEAD (-)');

END DELETE_VAR_BKPTS_HEAD;

/*===========================================================================+
| PROCEDURE
|    DELETE_VAR_BKPTS_DET
|
| DESCRIPTION
|    Delete breakpoint details records in PN_VAR_BKPTS_DET for a
|    breakpoint header record.
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|              PN_VAR_LINES_PKG.DELETE_ROW
|
| ARGUMENTS  : IN:
|                    p_bkpt_header_id
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Delete breakpoint details records in PN_VAR_BKPTS_DET for a
|              breakpoint header record.
|
| MODIFICATION HISTORY
|
|     17-NOV-2001  Daniel Thota  o Created
+===========================================================================*/

PROCEDURE DELETE_VAR_BKPTS_DET(p_bkpt_header_id IN NUMBER) IS

l_counter NUMBER := 0;

CURSOR c1 IS
  SELECT bkpt_detail_id
  FROM   pn_var_bkpts_det_ALL
  WHERE  bkpt_header_id = p_bkpt_header_id;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_DET (+)');

  FOR det_rec IN c1 LOOP

    PN_VAR_BKPTS_DET_PKG.DELETE_ROW(det_rec.bkpt_detail_id);

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_BKPTS_DET (-)');

END DELETE_VAR_BKPTS_DET;

/*===========================================================================+
| FUNCTION
|    FIND_IF_PERIOD_EXISTS
|
| DESCRIPTION
|    Finds if periods exists for a variable rent record
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Finds if periods exists for a variable rent record
|
| MODIFICATION HISTORY
|
|     05-SEP-2001  Daniel Thota  o Created
+===========================================================================*/

FUNCTION find_if_period_exists (p_var_rent_id NUMBER) RETURN NUMBER IS

l_period_exists NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_PERIOD_EXISTS (+)');

  SELECT 1
  INTO   l_period_exists
  FROM   dual
  WHERE  EXISTS ( SELECT periods.period_id
                  FROM   pn_var_periods_ALL periods
                  WHERE  periods.var_rent_id = p_var_rent_id);

  RETURN l_period_exists;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_PERIOD_EXISTS (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_period_exists;


/*===========================================================================+
| FUNCTION
|    FIND_IF_CALCULATION_EXISTS
|
| DESCRIPTION
|    Finds if calculation has been done for this variable rent.
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Finds if calculation has been done for this variable rent.
|
| MODIFICATION HISTORY
|
|  26-02-2007  piagrawa o Created
+===========================================================================*/

FUNCTION find_if_calculation_exists (p_var_rent_id NUMBER) RETURN NUMBER IS

l_calculation_exists NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CALCULATION_EXISTS (+)');

  SELECT 1
  INTO   l_calculation_exists
  FROM   dual
  WHERE  EXISTS ( SELECT inv.var_rent_inv_id
                  FROM   pn_var_rent_inv_all inv
                  WHERE  inv.var_rent_id = p_var_rent_id);

  RETURN l_calculation_exists;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CALCULATION_EXISTS (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_calculation_exists;

/*===========================================================================+
| FUNCTION
|    FIND_IF_INVOICE_EXISTS
|
| DESCRIPTION
|    Finds if invoices exists for a variable rent record
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Finds if invoices exists for a variable rent record
|
| MODIFICATION HISTORY
|
|     11-JAN-2007  Ram kumar  o Created
+===========================================================================*/

FUNCTION find_if_invoice_exists (p_var_rent_id NUMBER) RETURN NUMBER IS

l_invoice_exists NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_INVOICE_EXISTS (+)');

  SELECT 1
  INTO   l_invoice_exists
  FROM   dual
  WHERE  EXISTS ( SELECT inv.var_rent_inv_id
                  FROM   pn_var_rent_inv_all inv
                  WHERE  inv.var_rent_id = p_var_rent_id);

  RETURN l_invoice_exists;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_INVOICE_EXISTS (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_invoice_exists;

/*===========================================================================+
 | PROCEDURE
 |    DELETE_VAR_RENT_INVOICES
 |
 | DESCRIPTION
 |    Deletes variable rent Volumes, Deductions, Invoices and Terms created
 |    for a variable rent record
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_term_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     12-Jan-2007  Ram kumar  o Created
 +===========================================================================*/

PROCEDURE DELETE_VAR_RENT_INVOICES(p_var_rent_id IN NUMBER,
                                   p_term_date   IN DATE ) IS

l_lines_exist           NUMBER  := NULL;
l_constr_exist          NUMBER  := NULL;
l_date                  DATE;
l_volhist_exist         NUMBER;
l_deduct_exist          NUMBER;
l_counter               NUMBER;

CURSOR c1 is
  SELECT line_item_id
  FROM   pn_var_lines
  WHERE  period_id IN (SELECT period_id
                       FROM   pn_var_periods_ALL
                       WHERE  var_rent_id = p_var_rent_id
                       AND    start_date  > l_date
                       AND    end_date    > l_date);


BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_INVOICES (+)');

  l_date        := NVL(p_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

  l_lines_exist := PN_VAR_RENT_PKG.find_if_lines_exist(p_var_rent_id, NULL, l_date);

  l_constr_exist:= PN_VAR_RENT_PKG.find_if_constr_exist(p_var_rent_id, l_date);

  DELETE FROM pn_payment_items_all
  WHERE  payment_term_id IN
         (SELECT payment_term_id
          FROM   pn_payment_terms_all
          WHERE  var_rent_inv_id IN
                 (SELECT var_rent_inv_id
                  FROM  pn_var_rent_inv_all
                  WHERE var_rent_id = p_var_rent_id
                 )
         )
  AND export_to_ar_flag <>'Y'   ;

  DELETE FROM pn_payment_schedules_all
  WHERE  payment_schedule_id IN
         (SELECT payment_schedule_id
          FROM   pn_payment_items_all
          WHERE  export_to_ar_flag <>'Y'
          AND    payment_term_id IN
                 (SELECT payment_term_id
                  FROM   pn_payment_terms
                  WHERE  VAR_RENT_INV_ID IN
                         (SELECT var_rent_inv_id
                          FROM   pn_var_rent_inv_all
                          WHERE  var_rent_id = p_var_rent_id
                         )
                 )
         )
  AND payment_status_lookup_code <>'APPROVED';

  DELETE FROM  pn_var_rent_summ
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM pn_payment_terms
  WHERE var_rent_inv_id IN
        (SELECT var_rent_inv_id
         FROM   pn_var_rent_inv_all
         WHERE  var_rent_id = p_var_rent_id)
  AND   NOT EXISTS
        (SELECT 1
         FROM   pn_payment_items
         WHERE  export_to_ar_flag ='Y'
         AND    payment_term_id IN
                (SELECT payment_term_id
                 FROM pn_payment_terms
                 WHERE VAR_RENT_INV_ID IN
                       (SELECT VAR_RENT_INV_ID
                        FROM   PN_VAR_RENT_INV_ALL
                        WHERE VAR_RENT_ID = p_var_rent_id
                       )
                )
        );

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM  pn_var_rent_inv
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  FOR lines_rec IN c1 LOOP

      l_volhist_exist := PN_VAR_RENT_PKG.find_if_volhist_exist(lines_rec.line_item_id);
    -------------------------------------------------------------------------
    -- First delete volume history associated with each line associated with each
    -- period for this variable rent record
    -------------------------------------------------------------------------
    IF l_volhist_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_VOL_HIST(lines_rec.line_item_id);
    END IF;

    l_deduct_exist := PN_VAR_RENT_PKG.find_if_deduct_exist(lines_rec.line_item_id);
    -------------------------------------------------------------------------
    -- First delete deductions associated with each line associated with each
    -- period for this variable rent record
    -------------------------------------------------------------------------
    IF l_deduct_exist IS NOT NULL THEN
      PN_VAR_RENT_PKG.DELETE_VAR_RENT_DEDUCT(lines_rec.line_item_id);
    END IF;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DELETE_VAR_RENT_INVOICES (-)');

END DELETE_VAR_RENT_INVOICES;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_VRDATES_EXISTS
 |
 | DESCRIPTION
 |    Finds if Variable Rent Dates exists for a variable rent record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Variable Rent Dates exists for a variable rent record
 |
 | MODIFICATION HISTORY
 |
 |     12-OCT-2001  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION find_if_vrdates_exists (p_var_rent_id NUMBER) RETURN NUMBER IS

l_vrdates_exists NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VRDATES_EXISTS (+)');

  SELECT 1
  INTO   l_vrdates_exists
  FROM   dual
  WHERE  EXISTS ( SELECT dates.var_rent_date_id
                  FROM   pn_var_rent_dates_ALL dates
                  WHERE  dates.var_rent_id = p_var_rent_id);

  RETURN l_vrdates_exists;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VRDATES_EXISTS (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_vrdates_exists;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_LINES_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Lines exist for a variable rent record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_period_id
 |                    p_term_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Variable Rent Lines exist for a variable rent record
 |
 | MODIFICATION HISTORY
 |
 |     15-OCT-2001  Daniel Thota  o Created
 |     27-DEC-2001  Daniel Thota  o Included parameter p_term_date for contraction.
 +===========================================================================*/

FUNCTION find_if_lines_exist (p_var_rent_id NUMBER,
                              p_period_id   NUMBER,
                              p_term_date   DATE) RETURN NUMBER IS

l_lines_exist   NUMBER;
l_date          DATE;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_LINES_EXIST (+)');

  l_date            := nvl(p_term_date,(to_date('01/01/1776','mm/dd/yyyy')));

  SELECT 1
  INTO   l_lines_exist
  FROM   dual
  WHERE  EXISTS ( SELECT line_item_id
                  FROM   pn_var_lines_ALL
                  WHERE  period_id IN (SELECT period_id
                                       FROM   pn_var_periods_ALL
                                       WHERE  var_rent_id = p_var_rent_id
                                       AND    period_id   = NVL(p_period_id,period_id)
                                       AND    start_date  > l_date
                                       AND    end_date    > l_date)
                );

  RETURN l_lines_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_LINES_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_lines_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_VOLHIST_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Lines volume history exists for a variable rent record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Variable Rent Lines volume history exists for a variable rent record
 |
 | MODIFICATION HISTORY
 |
 |     30-NOV-2001  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION find_if_volhist_exist (p_line_item_id NUMBER) RETURN NUMBER IS

l_volhist_exist NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VOLHIST_EXIST (+)');

  SELECT 1
  INTO   l_volhist_exist
  FROM   dual
  WHERE  EXISTS ( SELECT vol_hist_id
                  FROM   pn_var_vol_hist_ALL
                  WHERE  line_item_id = p_line_item_id
                );

  RETURN l_volhist_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VOLHIST_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_volhist_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_VOLHIST_APPROVED_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Lines volume history exists for a variable rent record
 |    in approved status
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Variable Rent Lines volume history exists for a variable rent record
 |              in approved status
 |
 | MODIFICATION HISTORY
 |
 |     15-JUN-2004  Chris Thangaiyan  o Created
 +===========================================================================*/

FUNCTION find_if_volhist_approved_exist (p_line_item_id NUMBER
                                        ,p_grp_date_id  NUMBER)
RETURN VARCHAR2 IS

l_volhist_approved_exist   VARCHAR2(1);

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VOLHIST_APPROVED_EXIST (+)');

  SELECT 'Y'
  INTO   l_volhist_approved_exist
  FROM   dual
  WHERE  EXISTS ( SELECT vol_hist_id
                  FROM   pn_var_vol_hist_all
                  WHERE  line_item_id = p_line_item_id
                  AND    grp_date_id  = p_grp_date_id
                  AND    vol_hist_status_code = 'APPROVED'
                );

  RETURN l_volhist_approved_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_VOLHIST_APPROVED_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN 'N';

END find_if_volhist_approved_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_VOLHIST_BKPTS_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Lines volume history, Breakpoint Header and
 |    Breakpoints Details exists for a variable rent record.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |  p_id ( maybe a line_item_id OR period_id OR var_rent_id )
 |  p_id_type ( valid values are 'LINE_ITEM_ID' or 'PERIOD_ID' or 'VAR_RENT_ID' )
 |
 |              OUT:
 |
 | RETURNS : NUMBER
 |
 | NOTES   : Finds if Variable Rent Lines volume history, Breakpoint Header and
 |           Breakpoints Details exists for a variable rent record.
 |
 | IMP NOTE   : 1. p_id may be line_item_id OR period_id OR var_rent_id
 |              2. p_id_type can take on values
 |                      a. 'LINE_ITEM_ID' or
 |                      b. 'PERIOD_ID' or
 |                      c. 'VAR_RENT_ID'
 |
 | MODIFICATION HISTORY
 |
 |     26-JUN-2002  Kiran Hegde   o Created. Fix for bug#2173867.
 +===========================================================================*/

FUNCTION find_if_volhist_bkpts_exist ( p_id      NUMBER,
                                       p_id_type VARCHAR2 )
RETURN NUMBER IS

CURSOR c_bkptshd_line_item ( p_id IN NUMBER ) IS
  SELECT  bkpt_header_id, line_item_id
  FROM    pn_var_bkpts_head_ALL
  WHERE   line_item_id = p_id;

CURSOR c_bkptshd_period ( p_id IN NUMBER ) IS
  SELECT  bkpt_header_id, line_item_id
  FROM    pn_var_bkpts_head_ALL
  WHERE   period_id = p_id;

CURSOR c_bkptshd_var_rent ( p_id IN NUMBER ) IS
  SELECT  bkpt_header_id, line_item_id
  FROM    pn_var_bkpts_head_ALL
  WHERE   period_id IN ( SELECT   period_id
                         FROM     pn_var_periods_ALL
                         WHERE    var_rent_id = p_id );

l_volhist_bkpts_exist NUMBER := NULL;

BEGIN

  IF p_id_type = 'LINE_ITEM_ID' THEN

    FOR i IN c_bkptshd_line_item( p_id ) LOOP
      IF PN_VAR_RENT_PKG.find_if_volhist_exist( i.line_item_id ) IS NOT NULL THEN
        l_volhist_bkpts_exist := PN_VAR_RENT_PKG.find_if_bkptsdet_exist( i.bkpt_header_id );
        IF l_volhist_bkpts_exist IS NOT NULL THEN
          RETURN l_volhist_bkpts_exist;
        END IF;
      END IF;
    END LOOP;

  ELSIF p_id_type = 'PERIOD_ID' THEN

    FOR i in c_bkptshd_period ( p_id ) LOOP
      IF PN_VAR_RENT_PKG.find_if_volhist_exist( i.line_item_id ) IS NOT NULL THEN
        l_volhist_bkpts_exist := PN_VAR_RENT_PKG.find_if_bkptsdet_exist( i.bkpt_header_id );
        IF l_volhist_bkpts_exist IS NOT NULL THEN
          RETURN l_volhist_bkpts_exist;
        END IF;
      END IF;
    END LOOP;

  ELSIF p_id_type = 'VAR_RENT_ID' THEN

    FOR i IN c_bkptshd_var_rent ( p_id ) LOOP
      IF PN_VAR_RENT_PKG.find_if_volhist_exist( i.line_item_id ) IS NOT NULL THEN
        l_volhist_bkpts_exist := PN_VAR_RENT_PKG.find_if_bkptsdet_exist( i.bkpt_header_id );
        IF l_volhist_bkpts_exist IS NOT NULL THEN
          RETURN l_volhist_bkpts_exist;
        END IF;
      END IF;
    END LOOP;

  END IF;

  RETURN l_volhist_bkpts_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTS_EXIST (+)');

END find_if_volhist_bkpts_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_CONSTR_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Constraints exist for a variable rent period record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_term_date
 |
 |              OUT:
 |
 | RETURNS : None
 |
 | NOTES   : Finds if Variable Rent Constraints exist for a variable rent period record
 |
 | MODIFICATION HISTORY
 |
 |     03-DEC-2001  Daniel Thota  o Created
 |     27-DEC-2001  Daniel Thota  o Included parameter p_term_date for contraction.
 +===========================================================================*/

FUNCTION FIND_IF_CONSTR_EXIST (p_var_rent_id NUMBER,
                               p_term_date   DATE )
RETURN NUMBER IS

l_constr_exist   NUMBER;
l_date           DATE;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CONSTR_EXIST (+)');

  l_date := NVL(p_term_date,(TO_DATE('01/01/1776','mm/dd/yyyy')));

  SELECT 1
  INTO   l_constr_exist
  FROM   dual
  WHERE  EXISTS ( SELECT constraint_id
                  FROM   pn_var_constraints_ALL
                  WHERE  period_id IN (SELECT period_id
                                       FROM   PN_VAR_PERIODS_ALL
                                       WHERE  var_rent_id = p_var_rent_id
                                       AND    start_date  > l_date
                                       AND    end_date    > l_date)
                );

  RETURN l_constr_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CONSTR_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END FIND_IF_CONSTR_EXIST;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_ABAT_DEF_EXIST
 |
 | DESCRIPTION
 |    Finds if Fixed abatements and rolling allowances exist for a variable rent
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |
 |              OUT:
 |
 | RETURNS : None
 |
 | NOTES   : Finds if Fixed abatements and rolling allowances exist for a variable rent
 |           craeted at the time of setup
 | MODIFICATION HISTORY
 |
 |     15-MAY-2007  Lokesh  o Created for Bug # 6053747
 |
 +===========================================================================*/

FUNCTION FIND_IF_ABAT_DEF_EXIST (p_var_rent_id NUMBER)
RETURN NUMBER IS

l_abat_exist   NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_ABAT_DEF_EXIST (+)');

  SELECT 1
  INTO   l_abat_exist
  FROM   dual
  WHERE  EXISTS ( SELECT NULL
                  FROM   pn_var_abat_defaults_all
                  WHERE  var_rent_id = p_var_rent_id
                 );

  RETURN l_abat_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_ABAT_DEF_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END FIND_IF_ABAT_DEF_EXIST;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_CONSTR_DEF_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Constraints exist for a variable rent
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |
 |              OUT:
 |
 | RETURNS : None
 |
 | NOTES   : Finds if Variable Rent Constraints exist for a variable rent created
 |           at the time of setup
 |
 | MODIFICATION HISTORY
 |
 |     15-MAY-2007  Lokesh  o Created Bug # 6053747
 |
 +===========================================================================*/

FUNCTION FIND_IF_CONSTR_DEF_EXIST (p_var_rent_id NUMBER)
RETURN NUMBER IS

l_constr_exist   NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CONSTR_DEF_EXIST (+)');

  SELECT 1
  INTO   l_constr_exist
  FROM   dual
  WHERE  EXISTS ( SELECT NULL
                  FROM   pn_var_constr_defaults_all
                  WHERE  var_rent_id = p_var_rent_id
                 );

  RETURN l_constr_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_CONSTR_DEF_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END FIND_IF_CONSTR_DEF_EXIST;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_DEDUCT_EXIST
 |
 | DESCRIPTION
 |    Finds if Variable Rent Deductions exist for a variable rent line record
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_line_item_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Variable Rent Deductions exist for a variable rent line record
 |
 | MODIFICATION HISTORY
 |
 |     03-DEC-2001  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION find_if_deduct_exist (p_line_item_id NUMBER) RETURN NUMBER IS

l_deduct_exist   NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_DEDUCT_EXIST (+)');

  SELECT 1
  INTO   l_deduct_exist
  FROM   dual
  WHERE  EXISTS ( SELECT deduction_id
                  FROM   pn_var_deductions_ALL
                  WHERE  line_item_id = p_line_item_id
                );

  RETURN l_deduct_exist;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_DEDUCT_EXIST (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_deduct_exist;

/*===========================================================================+
 | FUNCTION
 |    LOCK_ROW_EXCEPTION
 |
 | DESCRIPTION
 |    Gives the statndard message for the offending column in a LOCK_ROW raised
 |    exception
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_column_name, p_new_value
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gives the statndard message for the offending column in a
 |              LOCK_ROW raised exception
 |
 | MODIFICATION HISTORY
 |
 |     15-OCT-2001  Daniel Thota  o Created
 +===========================================================================*/

PROCEDURE LOCK_ROW_EXCEPTION (p_column_name IN VARCHAR2,
                              p_new_value   IN VARCHAR2)
IS
BEGIN
  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION (+)');

  fnd_message.set_name ('PN','PN_RECORD_CHANGED');
  fnd_message.set_token ('COLUMN_NAME',p_column_name);
  fnd_message.set_token ('NEW_VALUE',p_new_value);
  app_exception.raise_exception;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION (-)');
END lock_row_exception;

/*===========================================================================+
 | FUNCTION
 |    First_Day
 |
 | DESCRIPTION
 |    Gives the first day of a month given any date
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_Date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gives the first day of a month given any date
 |
 | MODIFICATION HISTORY
 |
 |     22-OCT-2001  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION First_Day ( p_Date DATE ) RETURN DATE IS
BEGIN
  RETURN ADD_MONTHS(LAST_DAY(p_Date) + 1,  -1);
END First_Day;

/*===========================================================================+
 | FUNCTION
 |    FIND_REPORTING_PERIODS
 |
 | DESCRIPTION
 |    Finds the number of reporting periods in a period given a period_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_period_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds the number of reporting periods in a period given a period_id
 |
 | MODIFICATION HISTORY
 |
 | 26-OCT-2001  Daniel Thota  o Created
 | 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL table.
 +===========================================================================*/

FUNCTION find_reporting_periods (p_period_id NUMBER) RETURN NUMBER IS

l_reporting_periods   NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_REPORTING_PERIODS (+)');

  SELECT count(GRP_START_DATE)
  INTO   l_reporting_periods
  FROM   pn_var_grp_dates_all
  WHERE  period_id = p_period_id;

  RETURN l_reporting_periods;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_REPORTING_PERIODS (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_reporting_periods;

/*==============================================================================+
 | FUNCTION
 |    FIND_REPORTING_PERIODS
 |
 | DESCRIPTION
 |    Finds the number of reporting periods in a period given a p_freq_code
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:   p_freq_code
 |              OUT:  l_reporting_periods
 |
 | RETURNS    : None
 |
 | NOTES      : Finds the number of reporting periods in a period given a
 |              p_freq_code
 |
 | MODIFICATION HISTORY
 |
 |     12-APR-06  Pikhar     o Created
 +==============================================================================*/

FUNCTION find_reporting_periods (p_freq_code VARCHAR2) RETURN NUMBER IS

l_reporting_periods NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_REPORTING_PERIODS (+)');

  IF p_freq_code = 'MON' THEN

    RETURN 12;

  ELSIF p_freq_code = 'QTR' THEN

    RETURN 4;

  ELSIF p_freq_code = 'SA' THEN

    RETURN 2;

  ELSIF p_freq_code = 'YR' THEN

    RETURN 1;

  END IF;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_REPORTING_PERIODS (-)');

  RETURN l_reporting_periods;

EXCEPTION

  WHEN OTHERS THEN
     RETURN NULL;

END find_reporting_periods;

/*===========================================================================+
 | FUNCTION
 |    CALCULATE_BASE_RENT
 |
 | DESCRIPTION
 |    Calculates the base rent for a period given a var_rent_id and period_id
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_period_id
 |                    p_base_rent_type
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Calculates the base rent for a period given a var_rent_id,
 |              period_id and base_rent_type
 |
 | MODIFICATION HISTORY
 |
 | 15-NOV-01  Daniel Thota  o Created
 | 17-JAN-02  Daniel Thota  o Added p_base_rent_type
 | 26-DEC-02  Daniel Thota  o Removed the foll. predicate to fix bug # 2696773
 |                              term.start_date>= FIRST_DAY(per.start_date)
 | 14-JUN-05  hareesha o Bug 4284035 - Replaced pn_payment_schedules with _ALL table.
 +===========================================================================*/

FUNCTION CALCULATE_BASE_RENT (p_var_rent_id    NUMBER,
                              p_period_id      NUMBER,
                              p_base_rent_type VARCHAR2) RETURN NUMBER IS

l_base_rent NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CALCULATE_BASE_RENT (+)');

  IF (p_base_rent_type = 'ROLLING') THEN

    SELECT SUM(item.ACTUAL_AMOUNT)
    INTO   l_base_rent
    FROM   pn_payment_items_ALL item,
           pn_payment_terms_ALL term,
           pn_var_periods_ALL   per,
           pn_var_rents_ALL     var,
           pn_payment_schedules_all sched
    WHERE  item.PAYMENT_TERM_ID        = term.PAYMENT_TERM_ID
    AND    sched.PAYMENT_SCHEDULE_ID   = item.PAYMENT_SCHEDULE_ID
    AND    term.lease_id               = var.lease_id
    AND    var.var_rent_id             = p_var_rent_id
    AND    per.period_id               = p_period_id
    AND    per.var_rent_id             = p_var_rent_id
    AND    sched.SCHEDULE_DATE         >= FIRST_DAY(per.start_date)
    AND    sched.SCHEDULE_DATE         <=  per.end_date
    AND    term.PAYMENT_PURPOSE_CODE   = 'RENT'
    AND    term.PAYMENT_TERM_TYPE_CODE = 'BASER'
    AND    term.start_date             <= per.end_date
    AND    term.end_date               >= FIRST_DAY(per.start_date)
    AND    item.PAYMENT_ITEM_TYPE_LOOKUP_CODE = 'CASH'
    AND    term.currency_code          =  var.currency_code;

  ELSIF (p_base_rent_type = 'FIXED') THEN

    SELECT SUM(item.ACTUAL_AMOUNT)
    INTO   l_base_rent
    FROM   pn_payment_items_ALL item,
           pn_payment_terms_ALL term,
           pn_var_periods_ALL   per,
           pn_var_rents_ALL     var,
           pn_payment_schedules_all sched
    WHERE  item.PAYMENT_TERM_ID               = term.PAYMENT_TERM_ID
    AND    sched.PAYMENT_SCHEDULE_ID          = item.PAYMENT_SCHEDULE_ID
    AND    term.lease_id                      = var.lease_id
    AND    var.var_rent_id                    = p_var_rent_id
    AND    per.period_num                     = 1
    AND    per.var_rent_id                    = p_var_rent_id
    AND    sched.SCHEDULE_DATE                >= FIRST_DAY(per.start_date)
    AND    sched.SCHEDULE_DATE                <=  per.end_date
    AND    term.PAYMENT_PURPOSE_CODE          = 'RENT'
    AND    term.PAYMENT_TERM_TYPE_CODE        = 'BASER'
    AND    term.start_date                    <= per.end_date
    AND    term.end_date                      >= FIRST_DAY(per.start_date)
    AND    item.PAYMENT_ITEM_TYPE_LOOKUP_CODE = 'CASH'
    AND    term.currency_code =  var.currency_code;

  END IF;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.CALCULATE_BASE_RENT (-)');

  RETURN l_base_rent;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END CALCULATE_BASE_RENT;

/*===========================================================================+
 | FUNCTION
 |    GET_GRP_DATE_INFO
 |
 | DESCRIPTION
 |    Gets group date related info based on var_rent_id , period_id and start
 |    and end dates given as input
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_period_id
 |                    p_start_date
 |                    p_end_date
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets group date related info based on var_rent_id , period_id and star
 |              and end dates given as input
 |
 | MODIFICATION HISTORY
 |
 | 16-NOV-01  Daniel Thota  o Created
 | 21-NOV-03  Daniel Thota  o Added forecasted_exp_code to SELECT -- Fix for bug # 2435455
 | 14-JUN-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL table.
 +===========================================================================*/

FUNCTION get_grp_date_info (p_var_rent_id   IN NUMBER,
                            p_period_id     IN NUMBER,
                            p_start_date    IN DATE,
                            p_end_date      IN DATE) RETURN GRP_DATE_INFO_REC
IS

l_grp_date_info GRP_DATE_INFO_REC ;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.GET_GRP_DATE_INFO (+)');

  SELECT grp_date_id,
         grp_start_date,
         grp_end_date,
         group_date,
         reptg_due_date,
         inv_start_date,
         inv_end_date,
         invoice_date,
         inv_schedule_date,
         forecasted_exp_code
  INTO   l_grp_date_info
  FROM   pn_var_grp_dates_all
  WHERE  var_rent_id    = p_var_rent_id
  AND    period_id      = p_period_id
  AND    grp_start_date <= p_start_date
  AND    grp_start_date <= p_end_date
  AND    grp_end_date   >= p_start_date
  AND    grp_end_date   >= p_end_date
  AND    rownum = 1;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.GET_GRP_DATE_INFO (-)');

  RETURN l_grp_date_info;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name ('PN','PN_VAR_CHECK_DATES');
    APP_EXCEPTION.Raise_Exception;

  WHEN OTHERS THEN
    RETURN NULL;

END get_grp_date_info;

/*===========================================================================+
 | FUNCTION
 |    GET_PRORATION_FACTOR
 |
 | DESCRIPTION
 |    Gets proration factor information
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Gets proration factor information
 |
 | MODIFICATION HISTORY
 |
 | 27-DEC-01  Daniel Thota  o Created
 | 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL table.
 +===========================================================================*/

FUNCTION get_proration_factor(p_var_rent_id IN NUMBER)
RETURN PRORATION_FACTOR_REC IS

l_proration_factor       PRORATION_FACTOR_REC ;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.GET_PRORATION_FACTOR (+)');

  SELECT
    (p1.end_date-p1.start_date)+1 first_period_pro_days,
    p1.proration_factor first_period_gl_days,
    (p2.end_date-p2.start_date)+1 last_period_pro_days,
    p2.proration_factor last_period_gl_days,
    (g1.grp_end_date-g1.grp_start_date)+1 first_group_pro_days,
    g1.proration_factor first_group_gl_days,
    (g2.grp_end_date-g2.grp_start_date)+1 last_group_pro_days,
    g2.proration_factor last_group_gl_days
  INTO   l_proration_factor
  FROM   pn_var_periods_ALL p1, pn_var_periods_ALL p2,
         pn_var_grp_dates_ALL g1, pn_var_grp_dates_ALL g2
  WHERE  p1.var_rent_id = p2.var_rent_id
  AND    p1.var_rent_id = p_var_rent_id
  AND    g1.var_rent_id = g2.var_rent_id
  AND    g1.var_rent_id = p_var_rent_id
  AND    p1.period_id   = (SELECT min(period_id)
                           FROM   pn_var_periods_ALL
                           WHERE  var_rent_id = p_var_rent_id)
  AND    p2.period_id   = (SELECT max(period_id)
                           FROM   pn_var_periods_ALL
                           WHERE  var_rent_id = p_var_rent_id)
  AND    g1.grp_date_id = (SELECT min(grp_date_id)
                           FROM   pn_var_grp_dates
                           WHERE  var_rent_id = p_var_rent_id)
  AND    g2.grp_date_id = (SELECT max(grp_date_id)
                           FROM   pn_var_grp_dates
                           WHERE  var_rent_id = p_var_rent_id);

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.GET_PRORATION_FACTOR (-)');

  RETURN l_proration_factor;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;

END get_proration_factor;

/*===========================================================================+
| FUNCTION
|    FIND_IF_BKPTSHD_EXIST
|
| DESCRIPTION
|    Finds if Breakpoint header exists for a line item
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_line_item_id
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Finds if Breakpoint header exists for a line item
|
| MODIFICATION HISTORY
|
|     17-NOV-2001  Daniel Thota  o Created
+===========================================================================*/

FUNCTION find_if_bkptshd_exist (p_line_item_id NUMBER) RETURN NUMBER IS

l_bkptshd_exists NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTSHD_EXIST (+)');

  SELECT 1
  INTO   l_bkptshd_exists
  FROM   dual
  WHERE  EXISTS ( SELECT head.bkpt_header_id
                  FROM   pn_var_bkpts_head_ALL head
                  WHERE  head.line_item_id = p_line_item_id);

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTSHD_EXIST (-)');

  RETURN l_bkptshd_exists;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_bkptshd_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_BKPTSDET_EXIST
 |
 | DESCRIPTION
 |    Finds if Breakpoint Details exist for a breakpoint header
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_bkpt_header_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if Breakpoint Details exist for a breakpoint header
 |
 | MODIFICATION HISTORY
 |
 |     17-NOV-2001  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION find_if_bkptsdet_exist (p_bkpt_header_id NUMBER) RETURN NUMBER IS

l_bkptsdet_exist NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTSDET_EXIST (+)');

  SELECT 1
  INTO   l_bkptsdet_exist
  FROM   dual
  WHERE  EXISTS ( SELECT det.bkpt_detail_id
                  FROM   pn_var_bkpts_det_ALL det
                  WHERE  det.bkpt_header_id = p_bkpt_header_id);

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTSDET_EXIST (-)');

  RETURN l_bkptsdet_exist;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_bkptsdet_exist;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_EXPORTED
 |
 | DESCRIPTION
 |    Find if the given record has been exported.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                p_id
 |                p_block
 |                p_start_dt
 |                p_end_dt
 |
 |              OUT:
 |
 | RETURNS    : l_exported
 |
 | NOTES      : Find if the given record has been exported.
 |
 | MODIFICATION HISTORY
 |
 | 17-NOV-01  Daniel Thota  o Created
 | 16-Jan-03  Daniel Thota  o Added code to check if exported from
 |                            pn_var_rent_inv_all table.
 |                            Fix for bug # 2722191
 | 30-NOV-04  abanerje      o corrected the SELECT statement when
 |                            called FROM with p_block AS PERIODS_INV_BLK
 |                            Added brackets so that the join condition
 |                            IS evaluated correctly.
 |                            Bug 4026980
 | 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL table.
 | 12-Mar-07  Shabda   o Bug 5911819 - Volume records are considered exported
 |                       when actual or variance exp_code = y (Not forecasted exp_code)
 +===========================================================================*/

FUNCTION find_if_exported (p_id       IN NUMBER,
                           p_block    IN VARCHAR2,
                           p_start_dt IN DATE DEFAULT NULL,
                           p_end_dt   IN DATE DEFAULT NULL) RETURN NUMBER IS

l_exported NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_EXPORTED (+)');

  IF p_block IN('SUMMARY_FDR_BLK','VARENT_DATES_BLK') THEN

     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT grp_date_id
                     FROM   pn_var_grp_dates_all
                     WHERE  var_rent_id          = p_id
                     AND    (actual_exp_code     = 'Y' OR
                             forecasted_exp_code = 'Y')
                   );

  ELSIF p_block IN('CONSTRAINTS_BLK') THEN

     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT grp_date_id
                     FROM   pn_var_grp_dates_all
                     WHERE  period_id            = p_id
                     AND    (actual_exp_code     = 'Y' OR
                             forecasted_exp_code = 'Y')
                   );

  ELSIF p_block IN('LINE_ITEMS_BLK','BKPTS_HEADER_BLK','BKPTS_DETAIL_BLK','DEDUCTIONS_BLK') THEN

     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT grp_date_id
                     FROM   pn_var_grp_dates_all
                     WHERE  period_id       IN (SELECT period_id
                                                FROM   pn_var_lines_ALL
                                                WHERE  line_item_id = p_id)
                     AND    (actual_exp_code     = 'Y' OR
                             forecasted_exp_code = 'Y')
                   );

  ELSIF p_block IN('LINE_DEFAULTS_BLK','BKHD_DEFAULTS_BLK','BKDT_DEFAULTS_BLK') THEN
    IF p_start_dt IS NULL OR p_end_dt IS NULL THEN
      SELECT 1
      INTO   l_exported
      FROM   dual
      WHERE  EXISTS ( SELECT grp_date_id
                      FROM   pn_var_grp_dates_all
                      WHERE  period_id       IN (SELECT period_id
                                                 FROM   pn_var_lines_ALL
                                                 WHERE  line_default_id = p_id)
                      AND    (actual_exp_code     = 'Y' OR
                              forecasted_exp_code = 'Y')
                    );

    ELSE
      SELECT 1
      INTO   l_exported
      FROM   dual
      WHERE  EXISTS ( SELECT grp_date_id
                      FROM pn_var_grp_dates_all a,
                           pn_var_periods_all b,
                           pn_var_lines_all c
                      WHERE a.period_id = b.period_id
                      AND b.period_id   = c.period_id
                      AND c.line_default_id = p_id
                      AND (a.actual_exp_code     = 'Y' OR
                           a.forecasted_exp_code = 'Y')
                      AND ((b.start_date BETWEEN p_start_dt AND p_end_dt)
                        OR (b.end_date BETWEEN p_start_dt AND p_end_dt)
                        OR (p_start_dt BETWEEN b.start_date AND b.end_date)
                        OR (p_end_dt BETWEEN b.start_date AND b.end_date))
                    );
    END IF;

  ELSIF p_block IN('VOL_HIST_BLK') THEN

     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT vol_hist_id
                     FROM   pn_var_vol_hist_ALL
                     WHERE  vol_hist_id          = p_id
                     AND    (actual_exp_code     = 'Y' OR
                             variance_exp_code = 'Y')
                   );

  ELSIF p_block IN('PERIODS_INV_BLK') THEN -- Fix for bug # 2722191

     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT VAR_RENT_INV_ID
                     FROM   pn_var_rent_inv_all
                     WHERE  var_rent_inv_id     = p_id
                     AND    (actual_exp_code    = 'Y' OR
                             variance_exp_code  = 'Y')
                   );


  END IF;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_EXPORTED (-)');

  RETURN l_exported;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_exported;


/*===========================================================================+
 | FUNCTION
 |    FIND_IF_OR_VOL_EXPORTED
 |
 | DESCRIPTION
 |    Find if the given forecasted volume record has been exported.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                p_id
 |
 |              OUT:
 |
 | RETURNS    : l_exported
 |
 | NOTES      : Find if the given record has been exported.
 |
 | MODIFICATION HISTORY
 |
 | 12-Mar-2007  Shabda o Created
 +===========================================================================*/

FUNCTION find_if_for_vol_exported (p_id IN NUMBER) RETURN NUMBER IS

l_exported NUMBER;

BEGIN
  NULL;
  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_EXPORTED (+)');
     SELECT 1
     INTO   l_exported
     FROM   dual
     WHERE  EXISTS ( SELECT vol_hist_id
                     FROM   pn_var_vol_hist_ALL
                     WHERE  vol_hist_id          = p_id
                     AND    forecasted_exp_code = 'Y'
                   );

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_EXPORTED (-)');

  RETURN l_exported;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END find_if_for_vol_exported;


/*===========================================================================+
 | FUNCTION
 |    FIND_STATUS
 |
 | DESCRIPTION
 |    Finds if a period/line record is in 'OPEN','COMPLETE' or 'RECONCILED' status
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_period_id
 |                    p_invoice_on
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if a period/line record is in 'OPEN','COMPLETE' or 'RECONCILED' status
 |
 | MODIFICATION HISTORY
 |
 | 23-JAN-02  Daniel Thota  o Created
 | 21-Jun-02  Ashish Kumar  Fix BUG#2096829 and BUG#2096810 Change the Where clause of the
 |                          Completed and Reconciled Select stmts
 | 11-Jul-02  Ashish Kumar  Fix for BUG#2452276 In the Reconcile query change the
 |                          Forcasted_exp_code to Variance_exp_code
 | 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_grp_dates with _ALL table.
 +===========================================================================*/

FUNCTION find_status (p_period_id NUMBER) RETURN VARCHAR2 IS

l_status VARCHAR2(30);

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_STATUS (+)');

  SELECT 'COMPLETE'
  INTO   l_status
  FROM   dual
  WHERE  NOT EXISTS
        (SELECT grp_date_id
         FROM   pn_var_grp_dates_all
         WHERE  period_id = p_period_id
         AND   ((actual_exp_code = 'N' AND FORECASTED_exp_code ='N' AND variance_exp_code = 'N') OR
                (actual_exp_code = 'N' AND FORECASTED_exp_code ='Y' AND variance_exp_code = 'Y')
               )
        )
   AND   NOT EXISTS
        (SELECT vol_hist_id
         FROM   pn_var_vol_hist_ALL
         WHERE  period_id = p_period_id
         AND   ((actual_exp_code = 'N' AND FORECASTED_exp_code ='N' AND variance_exp_code = 'N') OR
                (actual_exp_code = 'N' AND FORECASTED_exp_code ='Y' AND variance_exp_code = 'Y')
               )
        );

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_STATUS (-)');

  RETURN l_status;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    BEGIN

      SELECT 'RECONCILED'
      INTO   l_status
      FROM   dual
      WHERE  NOT EXISTS(SELECT grp_date_id
                        FROM   pn_var_grp_dates_all
                        WHERE  period_id         = p_period_id
                        AND    variance_exp_code = 'N')
      AND    NOT EXISTS(SELECT vol_hist_id
                        FROM   pn_var_vol_hist_all
                        WHERE  period_id       = p_period_id
                        AND  VARIANCE_EXP_CODE ='N' );

      RETURN l_status;

    EXCEPTION
      WHEN OTHERS THEN
        l_status := 'OPEN';
        RETURN l_status;

    END;

END find_status;

/*===========================================================================+
 | FUNCTION
 |    FIND_IF_ADJUST_HIST_EXISTS
 |
 | DESCRIPTION
 |    Finds if a period has an adjustment history.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_period_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Finds if a period has an adjustment history.
 |
 | MODIFICATION HISTORY
 |
 |     22-FEB-2002  Daniel Thota  o Created
 +===========================================================================*/

FUNCTION find_if_adjust_hist_exists (p_period_id NUMBER) RETURN NUMBER IS

l_adjust_hist_exists NUMBER := NULL;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_ADJUST_HIST_EXISTS (+)');

  SELECT 1
  INTO   l_adjust_hist_exists
  FROM   dual
  WHERE  EXISTS(SELECT 1
                FROM  pn_var_rent_inv_ALL inv1
                WHERE inv1.period_id    = p_period_id
                AND   (NVL(inv1.adjust_num,0)  <> 0 OR
                       NVL(inv1.true_up_amt,0) <> 0 ));

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_ADJUST_HIST_EXISTS (-)');

  RETURN l_adjust_hist_exists;

  EXCEPTION

    WHEN OTHERS THEN
      RETURN NULL;

END find_if_adjust_hist_exists;

-------------------------------------------------------------------------------
-- FUNCTION   : APPROVED_TERM_EXIST
-- PARAMETERS : Variable_rent_id AND Period_id
-- HISTORY :
--   xx-xxx-xx   ashish   o To find any approved term exist for the var rent
--   05-JUL-04   anand    o Added another condition in the query
--                        o Coverted the INlINe query to CURSOR
--   ******** NOTE ********
--   Below IS the modIFied logic OF this function
--     IF (approved term exists) OR
--        (actual INvoiced amount IS 0
--         AND transferred IS checked FOR a INvoice OF thIS perticular period)
--     THEN
--       RETURN Y
--     ELSE
--       RETURN N
--     END IF;
--   ******** NOTE ********
-------------------------------------------------------------------------------

FUNCTION approved_term_exist (p_var_rent_id IN NUMBER,
                              p_period_id   IN NUMBER ) RETURN VARCHAR2 IS

CURSOR chk_term_cur IS
  SELECT 'Y' term_exists
  FROM   DUAL
  WHERE  EXISTS (SELECT NULL
                 FROM   pn_var_rent_inv_all INv,
                        pn_payment_terms_all pt
                 WHERE  inv.var_rent_id = p_var_rent_id
                 AND    inv.period_id =  NVL(p_period_id,inv.period_id)
                 AND    inv.var_rent_inv_id  = pt.var_rent_inv_id
                 AND    pt.status ='APPROVED'
                 AND    pt.var_rent_type IN ('ACTUAL','VARIANCE'))
  OR     EXISTS (SELECT NULL
                 FROM   pn_var_rent_inv_all pvri
                 WHERE  pvri.period_id = NVL(p_period_id,pvri.period_id)
                 AND    pvri.actual_invoiced_amount = 0
                 AND    actual_exp_code = 'Y'
                );

l_term_exISts VARCHAR2(1) := 'N';

BEGIN

  pnp_debug_pkg.debug( 'pn_var_rent_pkg.approved_term_exist (+): ');

  FOR chk_term_cur_rec IN chk_term_cur LOOP
    l_term_exists := chk_term_cur_rec.term_exists;
  END LOOP;

  pnp_debug_pkg.debug( 'pn_var_rent_pkg.approved_term_exist  (-): ');

  RETURN l_term_exists;

END approved_term_exist;

------------------------------------------------------------------------
-- PROCEDURE   : DELETE_INV_SUMM
-- PARAMETERS : Variable_rent_id
-- 24-Jul-2002   Ashish Kumar  o Fix BUG#2452909 created
-- FIX for BUG#2452909 created To delete all the Natural breakpoint
-- detials , summary, invoice , abatements and payment terms
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_var_bkpts_head with _ALL table.
---------------------------------------------------------------------

PROCEDURE delete_inv_summ (p_var_rent_id IN NUMBER) IS

CURSOR C_EXIST IS
  SELECT bp.bkpt_header_id
  FROM   pn_var_periods_all pd, pn_var_lines_all ln, pn_var_bkpts_head_all bp
  WHERE  pd.var_rent_id = p_var_rent_id
  AND    pd.period_id = ln.period_id
  AND    ln.lINe_item_id = bp.lINe_item_id
  AND    bp.break_type = 'NATURAL';

l_bkpt_header_id  NUMBER := 0;
l_bkptsdet_exISt  NUMBER := NULL;

BEGIN

  pnp_debug_pkg.debug( 'pn_var_rent_pkg.delet_INv_summ(+): ');

  OPEN c_exist;
  LOOP

    FETCH c_exist INTO l_bkpt_header_id;
    EXIT when c_exist%NOTFOUND;

    l_bkptsdet_exist := PN_VAR_RENT_PKG.find_if_bkptsdet_exist(l_bkpt_header_id);

    -------------------------------------------------------------------------
    -- first delete breakpoint details associated with each breakpoint header
    -------------------------------------------------------------------------
    IF l_bkptsdet_exist IS NOT NULL THEN
      pn_var_rent_pkg.delete_var_bkpts_det(l_bkpt_header_id);
    END IF;

    -----------------------------------------------------
    -- delete breakpoint header associated with each line
    -----------------------------------------------------
    pn_var_bkpts_head_pkg.delete_row(l_bkpt_header_id);

  END LOOP;

  DELETE FROM pn_var_rent_summ_all
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
   NULL;
  END IF;

  DELETE FROM pn_payment_terms_all
  WHERE var_rent_inv_id IN
         (SELECT var_rent_inv_id
          FROM   pn_var_rent_inv_all
          WHERE  var_rent_id = p_var_rent_id);

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM  pn_var_rent_inv_all
  WHERE var_rent_id = p_var_rent_id;

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  DELETE FROM pn_var_abatements_all
  WHERE  var_rent_inv_id IN
          (SELECT var_rent_inv_id
           FROM   pn_var_rent_inv_all
           WHERE  var_rent_id = p_var_rent_id);

  IF SQL%NOTFOUND THEN
    NULL;
  END IF;

  pnp_debug_pkg.debug( 'pn_var_rent_pkg.delet_INv_summ(-): ');

END delete_inv_summ;

/*===========================================================================+
 | FUNCTION
 |    FIND_VOL_READY_FOR_ADJUST
 |
 | DESCRIPTION
 |    To find records in the volume history table
 |    which are entered as an adjustment
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_period_id,p_invoice_on
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : To find records in the volume history table
 |              which are entered as an adjustment
 |
 | MODIFICATION HISTORY
 |
 |     16-Jan-2002  Daniel Thota  o Created Fix for bug # 2487686
 +===========================================================================*/

FUNCTION find_vol_ready_for_adjust (p_period_id  NUMBER,
                                    p_invoice_on VARCHAR2) RETURN NUMBER IS

l_vol_ready_for_adjust NUMBER := NULL;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_VOL_READY_FOR_ADJUST (+)');

  IF p_invoice_on = 'ACTUAL' THEN

    SELECT 1
    INTO   l_vol_ready_for_adjust
    FROM   dual
    WHERE  EXISTS(SELECT vh.grp_date_id
                  FROM   pn_var_vol_hist_all vh
                  WHERE  actual_exp_code = 'N'
                  AND    period_id = p_period_id
                  AND    EXISTS (SELECT grp.grp_date_id
                                 FROM   pn_var_grp_dates_all grp
                                 WHERE  actual_exp_code = 'Y'
                                 AND    grp.grp_date_id = vh.grp_date_id));

  ELSIF p_invoice_on = 'FORECASTED' THEN

    SELECT 1
    INTO   l_vol_ready_for_adjust
    FROM   dual
    WHERE  EXISTS(SELECT vh.grp_date_id
                  FROM   pn_var_vol_hist_all vh
                  WHERE  forecasted_exp_code = 'N'
                  AND    period_id = p_period_id
                  AND    EXISTS  (SELECT grp.grp_date_id
                                  FROM   pn_var_grp_dates_all grp
                                  WHERE  forecasted_exp_code = 'Y'
                                  AND    grp.grp_date_id = vh.grp_date_id));

  END IF;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_VOL_READY_FOR_ADJUST (-)');

  RETURN l_vol_ready_for_adjust;

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_vol_ready_for_adjust;

-------------------------------------------------------------------------------
--  NAME         : UPDATE_LOCATION_FOR_VR_TERMS()
--  PURPOSE      : UPDATEs the location ID FOR the terms ASsocaited with VR
--  DESCRIPTION  : UPDATEs the location ID FOR the terms ASsocaited with VR
--                 whenever the location ASsociated with VR agreement IS
--                 UPDATEd.
--  SCOPE        : PUBLIC
--  ARGUMENTS    : p_var_rent_id : variable rent ID.
--                 p_location_id : new location ID that terms to be UPDATEd with.
--                 p_return_status : return status OF the procedure
--  RETURNS      : None
--  HISTORY      :
--  03-JUN-04  ATUPPAD  o Created.
--                        FOR 'Edit location at VR Agreement' enhancement.
-------------------------------------------------------------------------------
PROCEDURE UPDATE_LOCATION_FOR_VR_TERMS(
          p_var_rent_id   IN  NUMBER,
          p_location_id   IN  NUMBER,
          p_return_status OUT NOCOPY VARCHAR2)
IS

CURSOR C_UPD_TERMS IS
  SELECT ppi.payment_term_id
  FROM   PN_PAYMENT_ITEMS_ALL ppi,
         PN_PAYMENT_TERMS_ALL ppt,
         PN_VAR_RENT_INV_ALL pvri,
         PN_LEASES_ALL pl
  WHERE  DECODE(pl.lease_class_code, 'DIRECT',      NVL(ppi.transferred_to_ap_flag,'N'),
                                     'THIRD_PARTY', NVL(ppi.transferred_to_ar_flag,'N'),
                                     'SUB_LEASE',   NVL(ppi.transferred_to_ar_flag,'N')) = 'N'
  AND    ppi.payment_term_id = ppt.payment_term_id
  AND    ppt.STATUS = 'APPROVED'
  AND    ppt.lease_id = pl.lease_id
  AND    ppt.var_rent_inv_id = pvri.var_rent_inv_id
  AND    pvri.var_rent_id = p_var_rent_id
  UNION ALL
  SELECT ppt.payment_term_id
  FROM   PN_PAYMENT_TERMS_ALL ppt,
         PN_VAR_RENT_INV_ALL pvri
  WHERE  ppt.STATUS = 'DRAFT'
  AND    ppt.var_rent_inv_id = pvri.var_rent_inv_id
  AND    pvri.var_rent_id = p_var_rent_id;

TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_payment_term_id number_tbl_type;

BEGIN
  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.UPDATE_LOCATION_FOR_VR_TERMS (+)');

  OPEN C_UPD_TERMS;
  LOOP
    FETCH C_UPD_TERMS
      BULK COLLECT INTO l_payment_term_id
      LIMIT 1000;

    FORALL i IN 1..l_payment_term_id.COUNT
      UPDATE PN_PAYMENT_TERMS_ALL
      SET    location_id = p_location_id
      WHERE  payment_term_id = l_payment_term_id(i);
    EXIT WHEN C_UPD_TERMS%NOTFOUND;

  END LOOP;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.UPDATE_LOCATION_FOR_VR_TERMS (-)');

  -- initialize api return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_LOCATION_FOR_VR_TERMS;

-------------------------------------------------------------------------------
--  NAME         : DATES_VALIDATION()
--  PURPOSE      : Vaidate Breakpoint Headers and details start and End dates
--  DESCRIPTION  :  It checks if the Bkpt
--                 headers and details dates have no overlaps or gaps.
--  SCOPE        : PUBLIC
--
--  ARGUMENTS    : p_var_rent_id : variable rent ID (mandatory)
--                 p_period_id   : Id of a particular period (optional)
--                 p_line_item_id: ID of a particular line item (optional)
--                 p_called_from : CAlled from SETUP or MAIN (mandatory)
--                 p_check for   : Checking for GAPS or OVERLAPS (mandatory)

--  RETURNS      : l_return_status
--  HISTORY      :
--
--  12-APR-06    Pikhar  o Created.
--
-------------------------------------------------------------------------------
FUNCTION  dates_validation (p_var_rent_id IN NUMBER
                           ,p_period_id IN NUMBER
                           ,p_line_item_id IN NUMBER
                           ,p_check_for IN VARCHAR2
                           ,p_called_from IN VARCHAR2) RETURN VARCHAR2
IS

/* cursors for main window - bkpt hrd, details, volumes */
CURSOR periods_vr_c(p_vr_id IN NUMBER) IS
SELECT period_id
      ,start_date
      ,end_date
FROM   pn_var_periods_all
WHERE  var_rent_id = p_vr_id
ORDER BY start_date;

CURSOR periods_c(p_prd_id IN NUMBER) IS
SELECT period_id
      ,start_date
      ,end_date
FROM   pn_var_periods_all
WHERE  period_id = p_prd_id;

CURSOR line_items_c(p_prd_id IN NUMBER) IS
SELECT line_item_id
FROM   pn_var_lines_all
WHERE  period_id = p_prd_id
ORDER BY line_item_id;

CURSOR bkpt_headers_c(p_line_id IN NUMBER) IS
SELECT bkhd_start_date
      ,bkhd_end_date
      ,bkpt_header_id
      ,breakpoint_type
FROM   pn_var_bkpts_head_all
WHERE  line_item_id = p_line_id
ORDER BY bkhd_start_date;

CURSOR bkpt_details_c(p_bkhd_id IN NUMBER) IS
SELECT bkpt_start_date
      ,bkpt_end_date
      ,COUNT(bkpt_detail_id) AS bkpt_count
FROM   pn_var_bkpts_det_all
WHERE  bkpt_header_id = p_bkhd_id
GROUP BY bkpt_start_date, bkpt_end_date
ORDER BY bkpt_start_date;

CURSOR bkpt_vol_c( p_bkhd_id IN NUMBER
      ,p_st_dt   IN DATE
      ,p_end_dt  IN DATE) IS
SELECT period_bkpt_vol_start
      ,period_bkpt_vol_end
FROM   pn_var_bkpts_det_all
WHERE  bkpt_header_id = p_bkhd_id
AND    bkpt_start_date = p_st_dt
AND    bkpt_end_date = p_end_dt
ORDER BY period_bkpt_vol_start;

CURSOR null_vols(p_bkhd_id IN NUMBER, p_start_date IN DATE) IS
SELECT count(*)
FROM   pn_var_bkpts_det_all
WHERE  bkpt_header_id = p_bkhd_id
AND    bkpt_start_date = p_start_date
AND    period_bkpt_vol_end IS NULL;


/* cursors for defaults - bkpt hrd, details, volumes */
CURSOR var_rent_c(p_vr_id IN NUMBER) IS
SELECT var_rent_id
      ,commencement_date
      ,termination_date
FROM   pn_var_rents_all
WHERE  var_rent_id = p_vr_id;

CURSOR line_defs_c(p_vr_id IN NUMBER) IS
SELECT line_default_id
FROM   pn_var_line_defaults_all
WHERE  var_rent_id = p_vr_id
ORDER BY line_default_id;

CURSOR bkpt_hdr_defs_c(p_line_def_id IN NUMBER) IS
SELECT bkhd_start_date
      ,bkhd_end_date
      ,bkhd_default_id
FROM   pn_var_bkhd_defaults_all
WHERE  line_default_id = p_line_def_id
ORDER BY bkhd_start_date;

CURSOR bkpt_dtl_defs_c(p_bkhd_def_id IN NUMBER) IS
SELECT bkdt_start_date
      ,bkdt_end_date
      ,COUNT(bkdt_default_id) AS bkpt_count
FROM   pn_var_bkdt_defaults_all
WHERE  bkhd_default_id = p_bkhd_def_id
GROUP BY bkdt_start_date, bkdt_end_date
ORDER BY bkdt_start_date;

CURSOR bkpt_vol_defs_c( p_bkhd_def_id IN NUMBER
                       ,p_st_dt       IN DATE
                       ,p_end_dt      IN DATE) IS
SELECT period_bkpt_vol_start
      ,period_bkpt_vol_end
FROM   pn_var_bkdt_defaults_all
WHERE  bkhd_default_id = p_bkhd_def_id
AND    bkdt_start_date = p_st_dt
AND    bkdt_end_date = p_end_dt
ORDER BY period_bkpt_vol_start;

CURSOR null_def_vols(p_bkhd_def_id IN NUMBER, p_start_date IN DATE) IS
SELECT count(*)
FROM   pn_var_bkdt_defaults_all
WHERE  bkhd_default_id = p_bkhd_def_id
AND    bkdt_start_date = p_start_date
AND    period_bkpt_vol_end IS NULL;

/* exceptions */
BAD_CALLED_FROM_EXCEPTION EXCEPTION;
GAP_FOUND_EXCEPTION EXCEPTION;
VOL_GAP_FOUND_EXCEPTION EXCEPTION;
OVERLAP_FOUND_EXCEPTION EXCEPTION;
DT_OUT_OF_PRD_RANGE_EXCEPTION EXCEPTION;
DT_OUT_OF_BKHD_RANGE_EXCEPTION EXCEPTION;

/* data structures */
TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DATE_TBL IS TABLE OF DATE INDEX BY BINARY_INTEGER;

/* period details */
l_period_t NUM_TBL;
l_period_st_dt_t DATE_TBL;
l_period_end_dt_t DATE_TBL;

/* line details */
l_line_t NUM_TBL;

/* other variables */
l_vr_comm_dt DATE;
l_vr_term_dt DATE;
l_period_st_dt DATE;
l_period_end_dt DATE;
l_prev_bkhd_start DATE;
l_prev_bkhd_end DATE;
l_hd_min_st_dt DATE;
l_dt_min_st_dt DATE;
l_prev_bkdt_start DATE;
l_prev_bkdt_end DATE;
l_prev_vol_start NUMBER;
l_prev_vol_end NUMBER;
l_bktd_num NUMBER;
l_volumes NUMBER;

l_bkhd_counter NUMBER;
l_bkdt_counter NUMBER;
l_vol_counter NUMBER;

l_return_status VARCHAR2(50) := 'N';

BEGIN

IF p_called_from = 'SETUP' THEN


  IF p_var_rent_id IS NOT NULL THEN
    FOR vr_rec IN var_rent_c(p_vr_id => p_var_rent_id) LOOP
      l_vr_comm_dt := vr_rec.commencement_date;
      l_vr_term_dt := vr_rec.termination_date;
    END LOOP;

  ELSE
    RAISE BAD_CALLED_FROM_EXCEPTION;

  END IF;

  l_line_t.DELETE;

  OPEN line_defs_c(p_vr_id => p_var_rent_id);
  FETCH line_defs_c BULK COLLECT INTO l_line_t;
  CLOSE line_defs_c;

  FOR line_rec IN l_line_t.FIRST..l_line_t.LAST LOOP

    l_bkhd_counter := 1;

    FOR bkhd_rec IN bkpt_hdr_defs_c(p_line_def_id => l_line_t(line_rec)) LOOP

      IF l_bkhd_counter = 1 THEN

        IF bkhd_rec.bkhd_start_date < l_vr_comm_dt THEN
          RAISE DT_OUT_OF_PRD_RANGE_EXCEPTION;
        END IF;

      ELSE

        IF bkhd_rec.bkhd_start_date
           > l_prev_bkhd_end + 1
        THEN
          IF p_check_for = 'GAPS' THEN
            /*RAISE GAP_FOUND_EXCEPTION;*/
            l_return_status := 'GAP_FOUND_EXCEPTION';
          END IF;

        ELSIF bkhd_rec.bkhd_start_date
          < l_prev_bkhd_end + 1 THEN
          RAISE OVERLAP_FOUND_EXCEPTION;

        END IF;

      END IF;

      l_prev_bkhd_start := bkhd_rec.bkhd_start_date;
      l_prev_bkhd_end := bkhd_rec.bkhd_end_date;
      l_bkhd_counter := l_bkhd_counter + 1;

      l_bkdt_counter := 1;

      SELECT count(*)
      INTO   l_bktd_num
      FROM   pn_var_bkdt_defaults_all
      WHERE  bkhd_default_id = bkhd_rec.bkhd_default_id;

      IF l_bktd_num = 0 THEN
         l_return_status := 'GAP_FOUND_EXCEPTION';
      ELSE

         FOR bkdt_rec IN bkpt_dtl_defs_c(p_bkhd_def_id => bkhd_rec.bkhd_default_id) LOOP

           IF l_bkdt_counter = 1 THEN

             IF bkdt_rec.bkdt_start_date < bkhd_rec.bkhd_start_date THEN
               RAISE DT_OUT_OF_BKHD_RANGE_EXCEPTION;

             ELSIF bkdt_rec.bkdt_start_date > bkhd_rec.bkhd_start_date THEN
               IF p_check_for = 'GAPS' THEN
                 /*RAISE GAP_FOUND_EXCEPTION;*/
                 l_return_status := 'GAP_FOUND_EXCEPTION';
               END IF;

             END IF;

           ELSE

             IF bkdt_rec.bkdt_start_date
              > l_prev_bkdt_end + 1
             THEN
               IF p_check_for = 'GAPS' THEN
                 /*RAISE GAP_FOUND_EXCEPTION;*/
                 l_return_status := 'GAP_FOUND_EXCEPTION';
               END IF;

             ELSIF bkdt_rec.bkdt_start_date
                < l_prev_bkdt_end + 1 THEN
               RAISE OVERLAP_FOUND_EXCEPTION;

             END IF;

           END IF;

           l_prev_bkdt_start := bkdt_rec.bkdt_start_date;
           l_prev_bkdt_end := bkdt_rec.bkdt_end_date;
           l_bkdt_counter := l_bkdt_counter + 1;

           /*Checking for volumes overlap */

           IF  bkdt_rec.bkpt_count > 1 THEN

             l_vol_counter := 1;

             FOR vol_rec IN bkpt_vol_defs_c(p_bkhd_def_id => bkhd_rec.bkhd_default_id
                                           ,p_st_dt => bkdt_rec.bkdt_start_date
                                           ,p_end_dt => bkdt_rec.bkdt_end_date) LOOP

               IF  l_vol_counter = 1 THEN
                 NULL;

               ELSE
                 IF vol_rec.period_bkpt_vol_start
                    > l_prev_vol_end
                 THEN
                   IF p_check_for = 'GAPS' THEN
                     /*RAISE GAP_FOUND_EXCEPTION;*/
                     l_return_status := 'VOL_GAP_FOUND_EXCEPTION';
                   END IF;

                 ELSIF vol_rec.period_bkpt_vol_start
                    < l_prev_vol_end THEN
                   RAISE OVERLAP_FOUND_EXCEPTION;
                 END IF;

               END IF;

               l_prev_vol_start := vol_rec.period_bkpt_vol_start;
               l_prev_vol_end := vol_rec.period_bkpt_vol_end;
               l_vol_counter := l_vol_counter + 1;

             END LOOP; /* loop for volumes */

             l_volumes := NULL;
             OPEN null_def_vols(p_bkhd_def_id => bkhd_rec.bkhd_default_id
                         ,p_start_date  => bkdt_rec.bkdt_start_date);
             FETCH null_def_vols INTO l_volumes;
             CLOSE  null_def_vols;

             IF l_volumes >1 THEN
                RAISE OVERLAP_FOUND_EXCEPTION;
             END IF;

           END IF;

         END LOOP; /* loop for bkdt */

         IF l_prev_bkdt_end >  bkhd_rec.bkhd_end_date THEN
           RAISE DT_OUT_OF_BKHD_RANGE_EXCEPTION;

         ELSIF l_prev_bkdt_end < bkhd_rec.bkhd_end_date THEN
           IF p_check_for = 'GAPS' THEN
             /*RAISE GAP_FOUND_EXCEPTION;*/
             l_return_status := 'GAP_FOUND_EXCEPTION';
           END IF;
         ELSE
           SELECT min(bkdt_start_date)
           INTO   l_dt_min_st_dt
           FROM   pn_var_bkdt_defaults_all
           WHERE  bkhd_default_id = bkhd_rec.bkhd_default_id;

           IF l_dt_min_st_dt > bkhd_rec.bkhd_start_date THEN
             IF p_check_for = 'GAPS' THEN
               /*RAISE GAP_FOUND_EXCEPTION;*/
               l_return_status := 'GAP_FOUND_EXCEPTION';
             END IF;
           END IF;

         END IF;

      END IF;

    END LOOP; /* loop for bkhd */

    IF l_prev_bkhd_end > l_vr_term_dt THEN
      RAISE DT_OUT_OF_PRD_RANGE_EXCEPTION;

    ELSIF l_prev_bkhd_end < l_vr_term_dt THEN
      IF p_check_for = 'GAPS' THEN
        /*RAISE GAP_FOUND_EXCEPTION;*/
        l_return_status := 'GAP_FOUND_EXCEPTION';
      END IF;
    ELSE
      SELECT min(bkhd_start_date)
      INTO   l_hd_min_st_dt
      FROM   pn_var_bkhd_defaults_all
      WHERE  line_default_id = l_line_t(line_rec);

      IF l_hd_min_st_dt > l_vr_comm_dt THEN
         IF p_check_for = 'GAPS' THEN
           /*RAISE GAP_FOUND_EXCEPTION;*/
           l_return_status := 'GAP_FOUND_EXCEPTION';
         END IF;
      END IF;
    END IF;

  END LOOP; /* loop for lines */

ELSIF p_called_from = 'MAIN' THEN

  l_period_t.DELETE;
  l_period_st_dt_t.DELETE;
  l_period_end_dt_t.DELETE;

  /* fetch period details */
  IF p_period_id IS NULL THEN

    IF p_var_rent_id IS NOT NULL THEN
      OPEN periods_vr_c(p_vr_id => p_var_rent_id);
      FETCH periods_vr_c BULK COLLECT INTO
       l_period_t
      ,l_period_st_dt_t
      ,l_period_end_dt_t;
      CLOSE periods_vr_c;

    ELSE
      RAISE BAD_CALLED_FROM_EXCEPTION;

    END IF;

  ELSE
    OPEN periods_c(p_prd_id => p_period_id);
    FETCH periods_c BULK COLLECT INTO
     l_period_t
    ,l_period_st_dt_t
    ,l_period_end_dt_t;
    CLOSE periods_c;

  END IF;

  IF l_period_t.FIRST IS NOT NULL THEN
    FOR prd_rec IN l_period_t.FIRST..l_period_t.LAST LOOP

      l_line_t.DELETE;

      IF p_line_item_id IS NULL THEN
        OPEN line_items_c(p_prd_id => l_period_t(prd_rec));
        FETCH line_items_c BULK COLLECT INTO l_line_t;
        CLOSE line_items_c;

        l_period_st_dt  := l_period_st_dt_t(prd_rec);
        l_period_end_dt := l_period_end_dt_t(prd_rec);

      ELSE
        l_line_t(1) := p_line_item_id;

        SELECT start_date , end_date
        INTO   l_period_st_dt, l_period_end_dt
        FROM   pn_var_periods_all
        WHERE  period_id =(SELECT period_id
                           FROM   pn_var_lines_all
                           WHERE  line_item_id = p_line_item_id);
      END IF;

      IF l_line_t.FIRST IS NOT NULL THEN
        FOR line_rec IN l_line_t.FIRST..l_line_t.LAST LOOP

          l_bkhd_counter := 1;

          FOR bkhd_rec IN bkpt_headers_c(p_line_id => l_line_t(line_rec)) LOOP

             IF l_bkhd_counter = 1 THEN

              IF bkhd_rec.bkhd_start_date < l_period_st_dt THEN
                RAISE DT_OUT_OF_PRD_RANGE_EXCEPTION;

              ELSIF bkhd_rec.bkhd_start_date > l_period_st_dt THEN
                IF p_check_for = 'GAPS' THEN
                  /*RAISE GAP_FOUND_EXCEPTION;*/
                  l_return_status := 'GAP_FOUND_EXCEPTION';
                END IF;

              END IF;

            ELSE

              IF bkhd_rec.bkhd_start_date
                 > l_prev_bkhd_end + 1
              THEN
                IF p_check_for = 'GAPS' THEN
                  /*RAISE GAP_FOUND_EXCEPTION;*/
                  l_return_status := 'GAP_FOUND_EXCEPTION';
                END IF;

              ELSIF bkhd_rec.bkhd_start_date
                 < l_prev_bkhd_end + 1 THEN
                RAISE OVERLAP_FOUND_EXCEPTION;

              END IF;

            END IF;

            l_prev_bkhd_start := bkhd_rec.bkhd_start_date;
            l_prev_bkhd_end := bkhd_rec.bkhd_end_date;
            l_bkhd_counter := l_bkhd_counter + 1;


            l_bkdt_counter := 1;

            FOR bkdt_rec IN bkpt_details_c(p_bkhd_id => bkhd_rec.bkpt_header_id) LOOP

              IF l_bkdt_counter = 1 THEN

                IF bkdt_rec.bkpt_start_date < bkhd_rec.bkhd_start_date THEN
                  RAISE DT_OUT_OF_BKHD_RANGE_EXCEPTION;

                ELSIF bkdt_rec.bkpt_start_date > bkhd_rec.bkhd_start_date THEN
                  IF p_check_for = 'GAPS' THEN
                    /*RAISE GAP_FOUND_EXCEPTION;*/
                    l_return_status := 'GAP_FOUND_EXCEPTION';
                  END IF;

                END IF;

              ELSE

                IF bkdt_rec.bkpt_start_date
                 > l_prev_bkdt_end + 1
                THEN
                  IF p_check_for = 'GAPS' THEN
                    /*RAISE GAP_FOUND_EXCEPTION;*/
                    l_return_status := 'GAP_FOUND_EXCEPTION';
                  END IF;

                ELSIF bkdt_rec.bkpt_start_date
                   < l_prev_bkdt_end + 1 THEN
                  RAISE OVERLAP_FOUND_EXCEPTION;

                END IF;

              END IF;

              l_prev_bkdt_start := bkdt_rec.bkpt_start_date;
              l_prev_bkdt_end := bkdt_rec.bkpt_end_date;
              l_bkdt_counter := l_bkdt_counter + 1;

              /*Checking for volumes overlap */

              IF  bkdt_rec.bkpt_count > 1 THEN

                l_vol_counter := 1;

                FOR vol_rec IN bkpt_vol_c(p_bkhd_id => bkhd_rec.bkpt_header_id
                                         ,p_st_dt => bkdt_rec.bkpt_start_date
                                         ,p_end_dt => bkdt_rec.bkpt_end_date) LOOP

                  IF  l_vol_counter = 1 THEN
                    NULL;

                  ELSE

                    IF vol_rec.period_bkpt_vol_start
                       > l_prev_vol_end
                    THEN
                      IF p_check_for = 'GAPS' THEN
                        /*RAISE VOL_GAP_FOUND_EXCEPTION;*/
                        l_return_status := 'VOL_GAP_FOUND_EXCEPTION';
                      END IF;

                    ELSIF vol_rec.period_bkpt_vol_start
                       < l_prev_vol_end  THEN
                      RAISE OVERLAP_FOUND_EXCEPTION;
                    END IF;

                  END IF;

                  l_prev_vol_start := vol_rec.period_bkpt_vol_start;
                  l_prev_vol_end := vol_rec.period_bkpt_vol_end;
                  l_vol_counter := l_vol_counter + 1;

                END LOOP; /* loop for volumes */

                l_volumes := NULL;
                OPEN null_vols(p_bkhd_id => bkhd_rec.bkpt_header_id
                  ,p_start_date => bkdt_rec.bkpt_start_date);
                FETCH null_vols INTO l_volumes;
                CLOSE  null_vols;

                IF l_volumes >1 THEN
                   RAISE OVERLAP_FOUND_EXCEPTION;
                END IF;

              END IF;

            END LOOP; /* loop for bkdt */

            IF l_prev_bkdt_end >  bkhd_rec.bkhd_end_date THEN
              RAISE DT_OUT_OF_BKHD_RANGE_EXCEPTION;

            ELSIF l_prev_bkdt_end < bkhd_rec.bkhd_end_date THEN
              IF p_check_for = 'GAPS' THEN
                /*RAISE GAP_FOUND_EXCEPTION;*/
                l_return_status := 'GAP_FOUND_EXCEPTION';
              END IF;

            END IF;

          END LOOP; /* loop for bkhd */

          IF l_prev_bkhd_end > l_period_end_dt THEN
            RAISE DT_OUT_OF_PRD_RANGE_EXCEPTION;

          ELSIF l_prev_bkhd_end < l_period_end_dt THEN
            IF p_check_for = 'GAPS' THEN
              /*RAISE GAP_FOUND_EXCEPTION;*/
              l_return_status := 'GAP_FOUND_EXCEPTION';
            END IF;

          END IF;

        END LOOP; /* loop for lines */
      END IF;

    END LOOP; /* loop for periods */
  END IF;

ELSE
  /* raise bad exception error */
  RAISE BAD_CALLED_FROM_EXCEPTION;

END IF;
RETURN l_return_status;

EXCEPTION
  WHEN BAD_CALLED_FROM_EXCEPTION THEN
    NULL;
    RETURN 'BAD_CALLED_FROM_EXCEPTION';
    /* write error log here */
  WHEN GAP_FOUND_EXCEPTION THEN
    l_return_status := 'GAP_FOUND_EXCEPTION';
    /* write error log here */
  WHEN VOL_GAP_FOUND_EXCEPTION THEN
    l_return_status := 'VOL_GAP_FOUND_EXCEPTION';
    /* write error log here */
  WHEN OVERLAP_FOUND_EXCEPTION THEN
    l_return_status := 'OVERLAP_FOUND_EXCEPTION';
    RETURN l_return_status;
    /* write error log here */
  WHEN DT_OUT_OF_PRD_RANGE_EXCEPTION  THEN
    NULL;
    RETURN 'DT_OUT_OF_BKHD_RANGE_EXCEPTION';
    /* write error log here */
  WHEN DT_OUT_OF_BKHD_RANGE_EXCEPTION  THEN
    NULL;
    RETURN 'DT_OUT_OF_BKHD_RANGE_EXCEPTION';
    /* write error log here */
  WHEN OTHERS THEN NULL;

RETURN l_return_status;

END dates_validation;

-------------------------------------------------------------------------------
--  NAME         : CONSTR_DATES_VALIDATION()
--  PURPOSE      : Vaidate overlap in constraints start and End dates
--  DESCRIPTION  :
--  SCOPE        : PUBLIC
--
--  ARGUMENTS    : p_var_rent_id : variable rent ID (mandatory)
--                 p_called_from : SETUP or MAIN
--

--  RETURNS      : l_return_status
--  HISTORY      :
--
--  12-APR-06    Pikhar  o Created.
--  14-MAR-07    Pikhar  o Changes for Bug 5930407
-------------------------------------------------------------------------------
FUNCTION CONSTR_DATES_VALIDATION (p_var_rent_id IN NUMBER
                                 ,p_called_from IN VARCHAR2) RETURN VARCHAR2
IS

TYPE constr_def_type   IS TABLE OF pn_var_constr_defaults_all%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE constr_type       IS TABLE OF pn_var_constraints_all%ROWTYPE INDEX BY BINARY_INTEGER;
constr_def_tab         constr_def_type;
constr_tab             constr_type;
l_C1_start_date        DATE;
l_C1_end_date          DATE;
l_C1_type_code         VARCHAR2(30);
l_C2_start_date        DATE;
l_C2_end_date          DATE;
l_C2_type_code         VARCHAR2(30);
l_C1_amount            NUMBER;
l_C2_amount            NUMBER;
i                      NUMBER;
l_var_rent_id          NUMBER;
l_vr_comm_dt           DATE;
l_vr_term_dt           DATE;
l_return_status        VARCHAR2(50) := 'N';

/* data structures */
TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DATE_TBL IS TABLE OF DATE INDEX BY BINARY_INTEGER;

/* period details */
l_period_t NUM_TBL;
l_period_st_dt_t DATE_TBL;
l_period_end_dt_t DATE_TBL;

CURSOR var_rent_c(p_vr_id IN NUMBER) IS
SELECT var_rent_id
      ,commencement_date
      ,termination_date
FROM   pn_var_rents_all
WHERE  var_rent_id = p_vr_id;

/* cursor for defaults - SETUP */
CURSOR constr_def_c IS
SELECT constr_default_id
      ,constr_start_date
      ,constr_end_date
      ,type_code
      ,amount
FROM   pn_var_constr_defaults_all
WHERE  var_rent_id = p_var_rent_id
ORDER BY constr_start_date;


/* cursors for main flow */
CURSOR periods_vr_c(p_vr_id IN NUMBER) IS
SELECT period_id
      ,start_date
      ,end_date
FROM   pn_var_periods_all
WHERE  var_rent_id = p_vr_id
ORDER BY start_date;

CURSOR periods_c(p_prd_id IN NUMBER) IS
SELECT period_id
      ,start_date
      ,end_date
FROM   pn_var_periods_all
WHERE  period_id = p_prd_id;

CURSOR constr_c(p_period_id IN NUMBER) IS
SELECT constraint_id
      ,constr_start_date
      ,constr_end_date
      ,type_code
FROM   pn_var_constraints_all
WHERE  period_id = p_period_id
ORDER BY constr_start_date;


OVERLAP_FOUND_EXCEPTION EXCEPTION;
DT_OUT_OF_RANGE_EXCEPTION EXCEPTION;
BAD_CALLED_FROM_EXCEPTION EXCEPTION;
MAX_LESS_THAN_MIN EXCEPTION;


BEGIN

IF p_var_rent_id IS NOT NULL THEN
   FOR vr_rec IN var_rent_c(p_vr_id => p_var_rent_id) LOOP
     l_vr_comm_dt := vr_rec.commencement_date;
     l_vr_term_dt := vr_rec.termination_date;
   END LOOP;
ELSE
   RAISE BAD_CALLED_FROM_EXCEPTION;
END IF;

IF p_called_from = 'SETUP' THEN

    i := 1;   /*This is used to feed data in PL/SQL table */

  FOR constr_cursor IN constr_def_c LOOP
      constr_def_tab(i).constr_start_date  := constr_cursor.constr_start_date;
      constr_def_tab(i).constr_end_date    := constr_cursor.constr_end_date;
      constr_def_tab(i).type_code          := constr_cursor.type_code;
      constr_def_tab(i).constr_default_id  := constr_cursor.constr_default_id;
      constr_def_tab(i).amount             := constr_cursor.amount;
      i := i+1;
  END LOOP;

  IF constr_def_tab.FIRST IS NOT NULL THEN
     FOR i IN  constr_def_tab.FIRST..constr_def_tab.LAST
     LOOP

        l_C1_start_date            := constr_def_tab(i).constr_start_date;
        l_C1_end_date              := constr_def_tab(i).constr_end_date;
        l_C1_type_code             := constr_def_tab(i).type_code;
        l_C1_amount                := constr_def_tab(i).amount;


        FOR j IN i..constr_def_tab.LAST
        LOOP
           l_C2_start_date            := constr_def_tab(j).constr_start_date;
           l_C2_end_date              := constr_def_tab(j).constr_end_date;
           l_C2_type_code             := constr_def_tab(j).type_code;
           l_C2_amount                := constr_def_tab(j).amount;

           /* Constraints of same type_code should not overlap for overlaping dates*/
           IF constr_def_tab(i).constr_default_id <> constr_def_tab(j).constr_default_id THEN
              IF l_C1_start_date BETWEEN l_C2_start_date AND l_C2_end_date OR
                 l_C2_start_date BETWEEN l_C1_start_date AND l_C1_end_date THEN
                 IF l_C1_type_code = l_C2_type_code THEN
                    RETURN 'OVERLAP_FOUND_EXCEPTION';
                 END IF;
                 /* Max constraint should not be less than Min Constraint */
                 IF (l_C1_type_code = 'MAX' AND l_C2_type_code = 'MIN' AND (l_C1_amount < l_C2_amount)) OR
                    (l_C2_type_code = 'MAX' AND l_C1_type_code = 'MIN' AND (l_C2_amount < l_C1_amount)) THEN
                      RETURN 'MAX_LESS_THAN_MIN';
                 END IF;
              END IF;
           END IF;

        END LOOP;
     END LOOP;
  END IF;

  RETURN l_return_status;

ELSIF p_called_from = 'MAIN' THEN

  l_period_t.DELETE;
  l_period_st_dt_t.DELETE;
  l_period_end_dt_t.DELETE;

  OPEN periods_vr_c(p_vr_id => p_var_rent_id);
  FETCH periods_vr_c BULK COLLECT INTO
   l_period_t
  ,l_period_st_dt_t
  ,l_period_end_dt_t;
  CLOSE periods_vr_c;

  IF l_period_t.FIRST IS NOT NULL THEN
     FOR prd_rec IN l_period_t.FIRST..l_period_t.LAST LOOP

        i := 1;   /*This is used to feed data in PL/SQL table */

        FOR constr_cursor IN constr_c(p_period_id => l_period_t(prd_rec)) LOOP
            constr_tab(i).constr_start_date  := constr_cursor.constr_start_date;
            constr_tab(i).constr_end_date    := constr_cursor.constr_end_date;
            constr_tab(i).type_code          := constr_cursor.type_code;
            constr_tab(i).constraint_id      := constr_cursor.constraint_id;
            i := i+1;
        END LOOP;

        FOR i IN  constr_tab.FIRST..constr_tab.LAST
        LOOP

           l_C1_start_date            := constr_tab(i).constr_start_date;
           l_C1_end_date              := constr_tab(i).constr_end_date;
           l_C1_type_code             := constr_tab(i).type_code;


           FOR j IN i..constr_tab.LAST
           LOOP
              l_C2_start_date         := constr_tab(j).constr_start_date;
              l_C2_end_date           := constr_tab(j).constr_end_date;
              l_C2_type_code          := constr_tab(j).type_code;

              /* Constraints of same type_code should not overlap for overlaping dates*/
              IF constr_tab(i).constraint_id <> constr_tab(j).constraint_id THEN
                 IF l_C1_start_date BETWEEN l_C2_start_date AND l_C2_end_date OR
                    l_C2_start_date BETWEEN l_C1_start_date AND l_C1_end_date THEN
                    IF l_C1_type_code = l_C2_type_code THEN
                       RETURN 'OVERLAP_FOUND_EXCEPTION';
                    END IF;
                 END IF;
              END IF;

           END LOOP;

        END LOOP;

     END LOOP; /*periods*/

  END IF;
  RETURN l_return_status;

END IF; /*validation for SETUP and MAIN complete*/

  RETURN l_return_status;

  EXCEPTION
    WHEN BAD_CALLED_FROM_EXCEPTION THEN
      RETURN 'BAD_CALLED_FROM_EXCEPTION';
    WHEN OVERLAP_FOUND_EXCEPTION THEN
      RETURN 'OVERLAP_FOUND_EXCEPTION';
    WHEN DT_OUT_OF_RANGE_EXCEPTION  THEN
      RETURN 'DT_OUT_OF_RANGE_EXCEPTION';
    WHEN MAX_LESS_THAN_MIN  THEN
      RETURN 'MAX_LESS_THAN_MIN';
    WHEN OTHERS THEN NULL;

END CONSTR_DATES_VALIDATION;

/*===========================================================================+
 | PROCEDURE
 |    extend_periods
 |
 | DESCRIPTION
 |   This procedure will be calles when the termination date of the VR
 |   agreement is extended or if the start date is changed to an earlier
 |   start date due to either change in the lease agreement or the VR
 |   agreement
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | CALLS     : extend_group_dates
 |
 | ARGUMENTS  : IN:
 |
 |          p_var_rent_id          - Variable rent id ( PK),
 |          p_extension_end_date   - new term date , NULL if no change
 |          p_start_date           - old start date, NULL if no change
 |          p_end_date             - old end date, NULL if no change
 |          p_cumulative_vol       - Cumulative Y/N,
 | ARGUMENTS  : OUT:
 |          x_return_status
 |          x_return_message
 |
 | MODIFICATION HISTORY
 |
 |     08-DEC-2002   graghuna o Created
 +===========================================================================*/
PROCEDURE extend_periods ( p_var_rent_id        IN NUMBER,
                           p_extension_end_date IN DATE,
                           p_start_date         IN DATE,
                           p_end_date           IN DATE,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_return_message     OUT NOCOPY VARCHAR2)
IS

    Cursor var_periods_cur IS
    SELECT  *
    FROM   pn_var_periods_all
    WHERE  var_rent_id = p_var_rent_id
   -- AND    (start_date = NVL(p_start_date,start_date) OR
   --         end_date   = NVL(p_end_date ,end_date) )
    Order by start_date ;

    CURSOR var_rent_dates_cur IS
    SELECT *
    FROM   pn_var_rent_dates_all
    WHERE  var_rent_id = p_var_rent_id ;

    l_row_found BOOLEAN  := FALSE;
    l_index     NUMBER := 0;
    l_number_of_new_periods NUMBER := 0;

    v_cal_periods_tbl cal_periods_tbl;
    v_new_periods_tbl new_periods_tbl;
    l_is_partial_period BOOLEAN := FALSE;
    l_partial_period    VARCHAR2(1) := 'N';

BEGIN

   -- First determine if the extension end date lies
   -- in the same period year or another period needs
   -- to be created

   FOR var_rent_dates_rec in var_rent_dates_cur
   LOOP
      pnp_debug_pkg.debug('inside var_rent_dates_rec loop');
      generate_cal_periods_tbl(p_var_rent_dates_rec => var_rent_dates_rec ,
                               p_start_date         => p_start_date,
                               p_end_date           => p_end_date,
                               p_extension_end_date => p_extension_end_date,
                               x_cal_periods_tbl    => v_cal_periods_tbl);
      FOR i in  v_cal_periods_tbl.FIRST .. v_cal_periods_tbl.LAST
      LOOP
        l_row_found := FALSE;
        FOR var_periods_rec in var_periods_cur
        LOOP
          IF  (v_cal_periods_tbl(i).start_date = var_periods_rec.start_date AND
               v_cal_periods_tbl(i).end_date = var_periods_rec.end_date ) THEN
            --put_log('found exact row....');
            l_row_found := TRUE;
            exit;
          ELSIF  (v_cal_periods_tbl(i).start_date = var_periods_rec.start_date AND
                  v_cal_periods_tbl(i).end_date > var_periods_rec.end_date ) THEN
            --put_log('found row to update....');
            l_row_found := TRUE;
            l_index := l_index + 1;
            v_new_periods_tbl(l_index).period_id   := var_periods_rec.period_id;
            v_new_periods_tbl(l_index).var_rent_id := p_var_rent_id;
            v_new_periods_tbl(l_index).start_date  := v_cal_periods_Tbl(i).start_date; --Srini
            v_new_periods_tbl(l_index).end_date    := v_cal_periods_Tbl(i).end_date;
            v_new_periods_tbl(l_index).flag        := 'U' ;
            exit;
          END IF; -- end if of if VR Preiod lies within the GL period.
        END LOOP; -- end loop for var_periods_rec in var_periods_cur LOOP

        IF NOT(l_row_found) THEN
            l_index := l_index + 1;
            l_number_of_new_periods := l_number_of_new_periods + 1;
            v_new_periods_tbl(l_index).flag := 'A' ;
            v_new_periods_tbl(l_index).var_rent_id := p_var_rent_id;
            v_new_periods_tbl(l_index).start_date := v_cal_periods_tbl(i).start_date;
            IF p_extension_end_date > v_cal_periods_tbl(i).end_date THEN
               v_new_periods_tbl(l_index).end_date := v_cal_periods_tbl(i).end_date ;
            ELSE
               v_new_periods_tbl(l_index).end_date := p_extension_end_date;
            END IF;
        END IF;
      END LOOP; -- end loop of v_cal_periods_tbl.FIRST .. v_cal_periods_tbl.LAST

      -- Process the update and then new inserts, if any
      FOR i in v_new_periods_tbl.FIRST .. v_new_periods_tbl.LAST
      LOOP
        IF v_new_periods_tbl(i).flag = 'U' THEN
          IF v_new_periods_tbl(i).end_date is NOT NULL THEN
            /*DELETE pn_var_transactions_all
            WHERE  period_id = v_new_periods_tbl(i).period_id ;*/

            --Srini Start 30-JUL-2004
            --Determine the new period is partial or full year
            l_is_partial_period := FALSE;
            /*
            l_is_partial_period := pn_var_trueup_ytd.is_partial_period (
                                        p_period_start_date => v_new_periods_tbl(i).start_date,
                                        p_period_end_date   => v_new_periods_tbl(i).end_date,
                                        p_gl_calendar       => var_rent_dates_rec.use_gl_calendar,
                                        p_period_set_name   => var_rent_dates_rec.gl_period_set_name ,
                                        p_period_type       => var_rent_dates_rec.period_type,
                                        p_cal_start_date    => var_rent_dates_rec.year_start_date);
            */
            IF l_is_partial_period THEN
              l_partial_period := 'Y';
            ELSE
              l_partial_period := 'N';
            END IF;
            /*pnp_debug_pkg.debug('  v_new_periods_tbl(i).start_date:'||v_new_periods_tbl(i).start_date);
            pnp_debug_pkg.debug('  v_new_periods_tbl(i).end_date:'||v_new_periods_tbl(i).end_date);
            pnp_debug_pkg.debug('  l_partial_period:'||l_partial_period);*/
            --Srini End 30-JUL-2004

            UPDATE pn_var_periods_all
            SET end_date          = v_new_periods_tbl(i).end_date,
                partial_period    = l_partial_period,   --Srini
                last_update_date  = sysdate,
                last_updated_by   = FND_GLOBAL.USER_ID,
                last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE period_id =  v_new_periods_tbl(i).period_id;
            put_log('updated period id '|| v_new_periods_tbl(i).period_id || ' with date = ' || v_new_periods_tbl(i).end_date);
          END IF;

          extend_group_dates(p_pn_var_rent_dates_rec => var_rent_dates_rec,
                             p_period_id             => v_new_periods_tbl(i).period_id,
                             x_return_status         => x_return_status,
                             x_return_message        => x_return_message);
        END IF;
      END LOOP; -- end loop for v_new_periods_tbl.FIRST .. v_new_periods_tbl.LAST

      FOR i in v_new_periods_tbl.FIRST .. v_new_periods_tbl.LAST
      LOOP
        IF v_new_periods_tbl(i).flag = 'A' THEN
          pn_var_rent_pkg.create_var_rent_periods_nocal(p_var_rent_id    => p_var_rent_id ,
                                                        p_cumulative_vol => 'Y' ,
                                                        p_yr_start_date  => var_rent_dates_rec.year_start_date);
        END IF;
      END LOOP; -- end loop for v_new_periods_tbl.FIRST .. v_new_periods_tbl.LAST

  END LOOP; --- end loop for var_rent_dates_rec will always have one row.

EXCEPTION
  WHEN OTHERS THEN
     fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
     fnd_message.set_token('ERR_MSG',sqlerrm);
     x_return_status := FND_API.G_RET_STS_ERROR;
     pnp_debug_pkg.put_log_msg (fnd_message.get);
     --PNP_DEBUG_PKG.disable_file_debug;

END extend_periods ;

/*===========================================================================+
 | PROCEDURE
 |    extend_group_dates
 |
 | DESCRIPTION
 |   This procedure will be calles when the termination date of the VR
 |   agreement is extended or if the start date is changed to an earlier
 |   start date due to either change in the lease agreement or the VR
 |   agreement
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | CALLS     : extend_group_dates
 |
 | ARGUMENTS  : IN:
 |
 |          p_pn_var_rent_dates_Rec          -
 |          p_period_id   -
 | ARGUMENTS  : OUT:
 |          x_return_status
 |          x_return_message
 |
 | MODIFICATION HISTORY
 |
 |     29-MAR-2003   Srini Vijayareddy o Created
 |
 |     31-MAY-2005   Ajay Solanki
 |     B88A - TEST - 37161: When using an Annual Reporting method, the breakpoints for the
 |     last partial period are not being prorated. We prorate for the first partial period,
 |     but use a annual breakpoint in the last period.
 |
 +===========================================================================*/
 PROCEDURE extend_group_dates (p_pn_var_rent_dates_rec IN  PN_VAR_RENT_DATES_ALL%ROWTYPE,
                               p_period_id             IN  NUMBER,
                               x_return_status         OUT NOCOPY VARCHAR2,
                               x_return_message        OUT NOCOPY VARCHAR2)
 IS
   CURSOR group_date_mon(p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT   min(start_date) start_date,  max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date        >= p_vr_comm_date
   AND      period_type = p_pn_var_rent_dates_rec.period_type
   AND      adjustment_period_flag = 'N'
   GROUP BY period_year, quarter_num, period_num
   ORDER BY start_date,end_date;

   CURSOR group_date_qtr(p_vr_comm_date DATE, p_vr_term_date DATE)IS
   SELECT   min(start_date) start_date,  max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date      >= p_vr_comm_date
   AND      quarter_num     IN(1,2,3,4)
   AND      period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY period_year, quarter_num
   ORDER BY start_date;

   CURSOR group_date_sa (p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT   min(g1.start_date) start_date
           ,max(g2.end_date) end_date
   FROM     gl_periods g1, gl_periods g2
   WHERE    g1.period_set_name(+) = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g2.period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g1.start_date(+)     <= p_vr_term_date
   AND      g2.end_date        >=  p_vr_comm_date
   AND      g1.quarter_num(+) = 1
   AND      g2.quarter_num = 2
   AND      g1.period_year(+) = g2.period_year
   AND      g1.start_date IS NOT NULL
   AND      g2.end_date IS NOT NULL
   AND      g1.period_type = p_pn_var_rent_dates_rec.period_type
   AND      g2.period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY g2.period_year
   UNION
   SELECT   min(g1.start_date) start_date
            ,max(g2.end_date) end_date
   FROM     gl_periods g1, gl_periods g2
   WHERE    g1.period_set_name(+) = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g2.period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g1.start_date(+)     <= p_vr_term_date
   AND      g2.end_date        >=  p_vr_comm_date
   AND      g1.quarter_num(+) = 3
   AND      g2.quarter_num = 4
   AND      g1.period_year (+)= g2.period_year
   AND      g1.start_date IS NOT NULL
   AND      g2.end_date IS NOT NULL
   AND      g1.period_type = p_pn_var_rent_dates_rec.period_type
   AND      g2.period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY g2.period_year
   order by 1;

   CURSOR group_date_ann (p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT min(start_date) start_date,max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date        >= p_vr_comm_date
   AND    period_type       = p_pn_var_rent_dates_rec.period_type
   GROUP BY period_year
   ORDER BY start_date;

   CURSOR periods_cur
   IS
     SELECT start_date, end_date ,proration_factor
     FROM   pn_var_periods_all
     WHERE  period_id = p_period_id;

   CURSOR pn_var_grp_dates_cur
   IS
     SELECT *
     FROM   pn_var_grp_dates_all
     WHERE  period_id = p_period_id
     ORDER BY grp_start_date;

   v_inv_dates_tbl   group_dates_tbl;

   l_period_start_date          DATE;
   l_period_end_date            DATE;
   l_proration_factor           NUMBER := 0;
   l_grpdateid                  NUMBER;
   l_period_proration_factor    NUMBER := 0;
   l_new_st_date                DATE;
   l_new_end_date               DATE;
   l_rptg_date                  DATE;
   l_inv_schedule_date          DATE;
   l_invoice_due_date           DATE;
   l_inv_st_date                DATE;
   l_year_st_date               DATE ;
   l_year_end_date              DATE ;
   l_grp_st_date                DATE ;
   l_grp_end_date               DATE ;
   l_rowid                      VARCHAR2(18);
   l_vr_comm_dt                 DATE;
   l_vr_term_dt                 DATE;
   l_inv_counter                NUMBER;
   l_invg_freq_code             NUMBER;
   l_reptg_freq_code            NUMBER;
   l_grp_counter                NUMBER := 0;
   l_inv_end_date               DATE := to_date('01/01/0001','mm/dd/yyyy');
   l_invoice_date               DATE;
   l_grp_inv_counter            NUMBER := 0;

   TYPE grp_date_rec is RECORD (l_grp_start_date        DATE,
                                l_grp_end_date          DATE,
                                l_group_date            DATE,
                                l_reptg_due_date        DATE,
                                l_inv_start_date        DATE,
                                l_inv_end_date          DATE,
                                l_invoice_date          DATE,
                                l_inv_schedule_date     DATE,
                                l_proration_factor      NUMBER,
                                l_rec_found             VARCHAR2(1));

   TYPE grp_date_table_type IS TABLE OF grp_date_rec INDEX BY BINARY_INTEGER;
   vr_grp_dates  grp_date_table_type;

 BEGIN
   SELECT commencement_date, termination_date
   INTO l_vr_comm_dt, l_vr_term_dt
   FROM pn_var_rents_all
   WHERE var_rent_id = p_pn_var_rent_dates_rec.var_rent_id;

   SELECT year_start_date
   INTO l_year_st_date
   FROM   pn_var_rent_dates_all
   WHERE  var_rent_id = p_pn_var_rent_dates_rec.var_rent_id;

   IF p_pn_var_rent_dates_rec.invg_freq_code = 'MON' THEN
     l_invg_freq_code := 1;
   ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'QTR' THEN
     l_invg_freq_code := 3;
   ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'SA' THEN
     l_invg_freq_code := 6;
   ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'YR' THEN
     l_invg_freq_code := 12;
   END IF;

   IF p_pn_var_rent_dates_rec.reptg_freq_code = 'MON' THEN
     l_reptg_freq_code := 1;
   ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'QTR' THEN
     l_reptg_freq_code := 3;
   ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'SA' THEN
     l_reptg_freq_code := 6;
   ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'YR' THEN
     l_reptg_freq_code := 12;
   END IF;

   FOR periods_rec in periods_cur
   LOOP
     l_period_start_date := periods_rec.start_date;
     l_period_end_date   := periods_rec.end_date;

     put_log('l_period start date = ' || l_period_start_date);
     put_log('l_period end_date' || l_period_end_date);

     -- determine reporting preiods
     IF NVL(p_pn_var_rent_dates_rec.use_gl_calendar,'N') = 'Y' THEN
       l_grp_counter    := 0;
       IF p_pn_var_rent_dates_rec.reptg_freq_code = 'MON' THEN
         FOR group_date_rec in group_date_mon(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_grp_counter := l_grp_counter + 1;
           vr_grp_dates(l_grp_counter).l_grp_start_date := group_date_rec.start_date;
           vr_grp_dates(l_grp_counter).l_grp_end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'QTR' THEN
         put_log('reporting = quarter');
         FOR group_date_rec in group_date_qtr(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_grp_counter := l_grp_counter + 1;
           vr_grp_dates(l_grp_counter).l_grp_start_date := group_date_rec.start_date;
           vr_grp_dates(l_grp_counter).l_grp_end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'SA' THEN
         FOR group_date_rec in group_date_sa(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_grp_counter := l_grp_counter + 1;
           vr_grp_dates(l_grp_counter).l_grp_start_date := group_date_rec.start_date;
           vr_grp_dates(l_grp_counter).l_grp_end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'YR' THEN
         FOR group_date_rec in group_date_ann(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_grp_counter := l_grp_counter + 1;
           vr_grp_dates(l_grp_counter).l_grp_start_date := group_date_rec.start_date;
           vr_grp_dates(l_grp_counter).l_grp_end_date := group_date_rec.end_date;
         END LOOP;
       END IF;

       -- determine invoice periods
       l_inv_counter := 0;
       IF p_pn_var_rent_dates_rec.invg_freq_code = 'MON' THEN
           l_inv_end_date := ADD_MONTHS(l_inv_st_date,1);
           v_inv_dates_tbl(l_inv_counter).start_date := l_inv_st_date;
           v_inv_dates_tbl(l_inv_counter).end_date := l_inv_end_date;
           l_inv_st_date := l_inv_end_date + 1;
         FOR group_date_rec in group_date_mon(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_inv_counter := l_inv_counter + 1;
           v_inv_dates_tbl(l_inv_counter).start_date := group_date_rec.start_date;
           v_inv_dates_tbl(l_inv_counter).end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'QTR' THEN
         FOR group_date_rec in group_date_qtr(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_inv_counter := l_inv_counter + 1;
           v_inv_dates_tbl(l_inv_counter).start_date := group_date_rec.start_date;
           v_inv_dates_tbl(l_inv_counter).end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'SA' THEN
         FOR group_date_rec in group_date_sa(l_period_start_date,
                                             l_period_end_date)
         LOOP
           l_inv_counter := l_inv_counter + 1;
           v_inv_dates_tbl(l_inv_counter).start_date := group_date_rec.start_date;
           v_inv_dates_tbl(l_inv_counter).end_date := group_date_rec.end_date;
         END LOOP;
       ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'YR' THEN
         FOR group_date_rec in group_date_ann(l_period_start_date,
                                              l_period_end_date)
         LOOP
           l_inv_counter := l_inv_counter + 1;
           v_inv_dates_tbl(l_inv_counter).start_date := group_date_rec.start_date;
           v_inv_dates_tbl(l_inv_counter).end_date := group_date_rec.end_date;
         END LOOP;
       END IF;
     ELSE
       -- use_gl_calendar = N
       -- determine reporting periods
       l_grp_counter    := 0;
       l_grp_st_date    := l_year_st_date;
       l_grp_end_date   := ADD_MONTHS(l_grp_st_date,l_reptg_freq_code)-1;

       WHILE l_grp_end_date < l_vr_comm_dt LOOP
         l_grp_st_date    := l_grp_end_date + 1;
         l_grp_end_date   := ADD_MONTHS(l_grp_st_date,l_reptg_freq_code)-1;
       END LOOP;

       vr_grp_dates(l_grp_counter).l_grp_start_date := l_vr_comm_dt;
       vr_grp_dates(l_grp_counter).l_grp_end_date   := l_grp_end_date;
       vr_grp_dates(l_grp_counter).l_group_date     := l_grp_st_date;
       vr_grp_dates(l_grp_counter).l_reptg_due_date :=
                        NVL( ((ADD_MONTHS(FIRST_DAY(vr_grp_dates(l_grp_counter).l_grp_end_date),1)-1)
                        + p_pn_var_rent_dates_rec.reptg_day_of_month), (vr_grp_dates(l_grp_counter).l_grp_end_date
                        + nvl(p_pn_var_rent_dates_rec.reptg_days_after,0)) );
       --vr_grp_dates(l_grp_counter).l_proration_factor :=
       --               (l_vr_comm_dt - l_grp_end_date)+1/(l_grp_st_date - LAST_DAY(l_grp_end_date))+1; --20MAY2004

       WHILE vr_grp_dates(l_grp_counter).l_grp_end_date < l_vr_term_dt LOOP
         l_grp_counter := l_grp_counter + 1;
         vr_grp_dates(l_grp_counter).l_grp_start_date := vr_grp_dates(l_grp_counter-1).l_grp_end_date + 1;
         vr_grp_dates(l_grp_counter).l_grp_end_date   := ADD_MONTHS(VR_grp_dates(l_grp_counter).l_grp_start_date,
                                                         l_reptg_freq_code) - 1;
         vr_grp_dates(l_grp_counter).l_group_date     := vr_grp_dates(l_grp_counter).l_grp_start_date;
         vr_grp_dates(l_grp_counter).l_reptg_due_date :=
             NVL( ((ADD_MONTHS(FIRST_DAY(vr_grp_dates(l_grp_counter).l_grp_end_date),1)-1) + p_pn_var_rent_dates_rec.reptg_day_of_month),
                  (vr_grp_dates(l_grp_counter).l_grp_end_date + nvl(p_pn_var_rent_dates_rec.reptg_days_after,0)) );
         --vr_grp_dates(l_grp_counter).l_proration_factor := 1; --20MAY2004
       END LOOP;
       vr_grp_dates(l_grp_counter).l_grp_end_date   := l_vr_term_dt;

       -- determine invoice periods
       l_inv_counter    := 0;
       l_inv_st_date    := l_year_st_date;
       l_inv_end_date   := l_year_st_date;

       WHILE l_inv_end_date < l_vr_term_dt
       LOOP
         IF l_inv_counter = 0 THEN
           l_inv_st_date    := l_year_st_date;
           l_inv_end_date   := ADD_MONTHS(l_inv_st_date,l_invg_freq_code)-1;

           WHILE l_inv_end_date < l_vr_comm_dt
           LOOP
             l_inv_st_date    := l_inv_end_date + 1;
             l_inv_end_date   := ADD_MONTHS(l_inv_st_date,l_invg_freq_code)-1;
           END LOOP;

           l_invoice_date   := l_inv_st_date;
           l_inv_st_date    := l_vr_comm_dt;
         ELSE
           l_inv_st_date    := l_inv_end_date + 1;
           l_inv_end_date   := ADD_MONTHS(l_inv_st_date,l_invg_freq_code)-1;
           l_invoice_date   := l_inv_st_date;
         END IF;

         l_inv_schedule_date := NVL(((ADD_MONTHS(FIRST_DAY(l_inv_end_date),1)-1)
                                + p_pn_var_rent_dates_rec.invg_day_of_month), (l_inv_end_date
                                + NVL(p_pn_var_rent_dates_rec.invg_days_after,0)));

         IF l_inv_end_date > l_vr_term_dt THEN
           l_inv_end_date := l_vr_term_dt;
         END IF;

         IF TO_NUMBER(TO_CHAR(l_inv_schedule_date,'dd')) in (29,30,31) THEN
           l_inv_schedule_date:= (FIRST_DAY(l_inv_schedule_date)+27);
         END IF;

         FOR i IN l_grp_inv_counter..VR_grp_dates.COUNT-1 LOOP
           EXIT WHEN VR_grp_dates(i).l_grp_start_date > l_inv_end_date;
           VR_grp_dates(i).l_inv_start_date     := l_inv_st_date;
           VR_grp_dates(i).l_inv_end_date       := l_inv_end_date;
           VR_grp_dates(i).l_invoice_date       := l_invoice_date;
           VR_grp_dates(i).l_inv_schedule_date  := l_inv_schedule_date;
           l_grp_inv_counter                    := l_grp_inv_counter + 1;
         END LOOP;
         l_inv_counter := l_inv_counter + 1;
       END LOOP;
     END IF;            -- end if of gl_calendar = Y

     FOR pn_var_grp_dates_rec IN pn_var_grp_dates_cur
     LOOP
       FOR i IN vr_grp_dates.FIRST .. vr_grp_dates.LAST
       LOOP
         IF (vr_grp_dates(i).l_grp_start_date = pn_var_grp_dates_rec.grp_start_date AND
          vr_grp_dates(i).l_grp_end_date   =  pn_var_grp_dates_rec.grp_end_date )
           THEN
           --put_log('Same groups  found');
           vr_grp_dates(i).l_rec_found := 'X';
         END IF;

         IF vr_grp_dates(i).l_grp_end_date <> pn_var_grp_dates_rec.grp_end_date AND
           vr_grp_dates(i).l_grp_start_date = pn_var_grp_dates_rec.grp_start_date THEN
           --put_log('Updating end dates');
           vr_grp_dates(i).l_rec_found := 'X';
           l_new_st_date := nvl(l_new_st_date,pn_var_grp_dates_rec.grp_start_date);
           l_new_end_date := vr_grp_dates(i).l_grp_end_date;

           IF p_pn_var_rent_dates_rec.reptg_day_of_month IS NOT NULL THEN
             l_rptg_date :=(ADD_MONTHS(FIRST_DAY(vr_grp_dates(i).l_grp_end_date),1)-1)+
                            p_pn_var_rent_dates_rec.reptg_day_of_month;
           ELSE
             l_rptg_date := vr_grp_dates(i).l_grp_end_date +
                             NVL(p_pn_var_rent_dates_rec.reptg_days_after,0);
           END IF;

--Code commented Ajay Solanki, 31-MAY-2005 according to mail from Jagan on Mon, 30 May 2005 12:46:54 -0700

--           vr_grp_dates(i).l_proration_factor := ((vr_grp_dates(i).l_grp_end_date -
--                                                 vr_grp_dates(i).l_grp_start_date) +1 )/
--                                                       ((last_day(vr_grp_dates(i).l_grp_end_date) -
--                                                 vr_grp_dates(i).l_group_date)+1); --Chris.T. 20MAY2004

--End Code commented Ajay Solanki, 31-MAY-2005 according to mail from Jagan on Mon, 30 May 2005 12:46:54 -0700


--New Code Ajay Solanki, 31-MAY-2005 according to mail from Jagan on Mon, 30 May 2005 12:46:54 -0700

          vr_grp_dates(i).l_proration_factor := ((vr_grp_dates(i).l_grp_end_date -
              vr_grp_dates(i).l_grp_start_date) +1 )/
              ((LAST_DAY(ADD_MONTHS(LAST_DAY(vr_grp_dates(i).l_group_date),l_reptg_freq_code-1)) -
              vr_grp_dates(i).l_group_date)+1);

--End New Code Ajay Solanki, 31-MAY-2005 according to mail from Jagan on Mon, 30 May 2005 12:46:54 -0700

           --Srini
           IF vr_grp_dates(i).l_proration_factor = 0 THEN
             put_log('  GRP Start Date While Updating Group Dates:'||vr_grp_dates(i).l_grp_start_date);
             put_log('  GRP End Date While Updating Group Dates:'||vr_grp_dates(i).l_grp_end_date);
             put_log('  Group Date While Updating Group Dates:'||vr_grp_dates(i).l_group_date);
             --vr_grp_dates(i).l_proration_factor := 1;
           END IF;

           UPDATE pn_var_grp_dates_all
           SET    grp_end_date = vr_grp_dates(i).l_grp_end_date ,
                  proration_factor = round(vr_grp_dates(i).l_proration_factor,10),  --Chris.T. 20MAY2004
                  last_update_date = sysdate,
                  last_updated_by  = FND_GLOBAL.USER_ID,
                  last_update_login = FND_GLOBAL.LOGIN_ID
           WHERE  grp_date_id  =  pn_var_grp_dates_rec.grp_date_id;

           /*UPDATE pn_var_transactions_all
           SET bkpt_end_date     = vr_grp_dates(i).l_grp_end_date,
               last_update_date  = SYSDATE,
               last_updated_by   = FND_GLOBAL.USER_ID,
               last_update_login = FND_GLOBAL.LOGIN_ID
           WHERE grp_date_id     = pn_var_grp_dates_rec.grp_date_id;*/

         END IF;        -- end if of end date not being equal
       END LOOP;        -- end loop for groups table.
     END LOOP;          -- end loop for pn_var_grp_dates_rec

     FOR i in vr_grp_dates.FIRST .. vr_grp_dates.LAST
     LOOP
       IF vr_grp_dates(i).l_rec_found is NULL THEN
         IF NVL(p_pn_var_rent_dates_rec.use_gl_calendar,'N') = 'N' THEN
           l_inv_st_date        := vr_grp_dates(i).l_inv_start_date;
           l_inv_end_date       := vr_grp_dates(i).l_inv_end_date;
           l_invoice_due_date   := vr_grp_dates(i).l_invoice_date;
           l_inv_schedule_date  := vr_grp_dates(i).l_inv_schedule_date;
           l_rptg_date          := vr_grp_dates(i).l_reptg_due_date;
         ELSE
           l_inv_st_date        := NULL;
           l_inv_end_date       := NULL;
           l_invoice_due_date   := NULL;
           l_inv_schedule_date  := NULL;
           l_rptg_date          := vr_grp_dates(i).l_grp_start_date;
         END IF;

         vr_grp_dates(i).l_proration_Factor:= ((vr_grp_dates(i).l_grp_end_date -
                                                vr_grp_dates(i).l_grp_start_date) +1 )/
                                              ((last_day(vr_grp_dates(i).l_grp_end_date) -
                                                vr_grp_dates(i).l_group_date)+1); --Chris.T. 20MAY2004
         --Srini
         IF vr_grp_dates(i).l_proration_factor = 0 THEN
           put_log('  GRP Start Date While Creating New Group Dates:'||vr_grp_dates(i).l_grp_start_date);
           put_log('  GRP End Date While Creating New Group Dates:'||vr_grp_dates(i).l_grp_end_date);
           put_log('  Group Date While Creating New Group Dates:'||vr_grp_dates(i).l_group_date);
           --vr_grp_dates(i).l_proration_factor := 1;
         END IF;

         IF vr_grp_dates(i).l_grp_start_date >= l_period_start_date AND
            vr_grp_dates(i).l_grp_end_date <= l_period_end_date THEN
           --put_log('-----------------------------------------');
           put_log(' Creating new group  ');
           PN_VAR_RENT_PKG.INSERT_GRP_DATE_ROW(
                                  x_rowid               => l_rowId,
                                  x_grp_date_id         => l_grpDateId,
                                  x_var_rent_id         => p_pn_var_rent_dates_rec.var_rent_id,
                                  x_period_id           => p_period_id,
                                  x_grp_start_date      => vr_grp_dates(i).l_grp_start_date,
                                  x_grp_end_date        => vr_grp_dates(i).l_grp_end_date,
                                  x_group_date          => vr_grp_dates(i).l_group_date,
                                  x_reptg_due_date      => l_rptg_date,
                                  x_inv_start_date      => l_inv_st_date,
                                  x_inv_end_date        => l_inv_end_date,
                                  x_invoice_date        => l_invoice_due_date,
                                  x_inv_schedule_date   => l_inv_schedule_date,
                                  x_proration_factor    => vr_grp_dates(i).l_proration_factor, --20MAY2004
                                  x_actual_exp_code     => 'N',
                                  x_forecasted_exp_code => 'N',
                                  x_variance_exp_code   => 'N',
                                  x_creation_date       => SYSDATE,
                                  x_created_by          => NVL(FND_PROFILE.VALUE('USER_ID'),1),
                                  x_last_update_date    => SYSDATE,
                                  x_last_updated_by     => NVL(FND_PROFILE.VALUE('USER_ID'),1),
                                  x_last_update_login   => NVL(FND_PROFILE.VALUE('USER_ID'),1));

           l_rowId        := NULL;
           l_grpDateId    := NULL;
         END IF;
       END IF;

     END LOOP ;

   END LOOP;

   IF NVL(p_pn_var_rent_dates_rec.use_gl_calendar,'N') = 'Y' THEN
     pn_var_rent_pkg.create_var_rent_periods(
                        p_var_rent_id    => p_pn_var_rent_dates_rec.var_rent_id,
                        p_cumulative_vol => 'Y',
                        p_comm_date      => l_vr_comm_dt,
                        p_term_date      => l_vr_term_dt,
                        p_create_flag    => 'N');
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
       pnp_debug_pkg.debug('error ' || sqlerrm);
       fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
       fnd_message.set_token('ERR_MSG',sqlerrm);
       x_return_status := FND_API.G_RET_STS_ERROR;
       pnp_debug_pkg.debug (fnd_message.get);
       pnp_debug_pkg.put_log_msg (fnd_message.get);
       --PNP_DEBUG_PKG.disable_file_debug;
 END extend_group_dates;

 /*===========================================================================+
 | PROCEDURE
 |    create_new_bkpts
 |
 | DESCRIPTION
 |   This procedure will be called when the termination date of the VR
 |   agreement is extended and user selects to create new breakpoints rather than extending
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 | CALLS     : None
 |
 | ARGUMENTS  : IN:
 |
 |          p_var_rent_id          - var_rent_id of the VR which got extended.( PK),
 |          p_extension_end_date   - new term date , NULL if no change
 |          p_old_end_date         - old end date, NULL if no change
 | ARGUMENTS  : OUT:
 |          x_return_status
 |          x_return_message
 |
 | MODIFICATION HISTORY
 |
 |     29-MAR-2004   Srini Vijayareddy o Created
 +===========================================================================*/
 PROCEDURE create_new_bkpts(p_var_rent_id        IN  NUMBER,
                            p_extension_end_date IN  DATE,
                            p_old_end_date       IN  DATE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_return_message     OUT NOCOPY VARCHAR2)
 IS
   CURSOR main_vr_cur
   IS
     SELECT var_rent_id,
            commencement_date start_date,
            termination_date end_date,
            cumulative_vol
     FROM   pn_var_rents_all
     WHERE var_rent_id = p_var_rent_id;

   errbuf  VARCHAR2(5000);
   retcode VARCHAR2(5000);
   l_default VARCHAR2(1);

 BEGIN
   put_log ('PN_VAR_RENT_PKG.create_new_bkpts (+)');
   FOR main_vr_rec in main_vr_cur
   LOOP
     UPDATE pn_var_rents_all
     SET termination_date = p_extension_end_date
     WHERE var_rent_id    = main_vr_rec.var_rent_id;

     put_log ('Starting Extension of Periods and group Dates');
     extend_periods(p_var_rent_id        => main_vr_rec.var_rent_id,
                    p_extension_end_date => p_extension_end_date,
                    p_start_date         => main_vr_rec.start_date,
                    p_end_date           => main_vr_rec.end_date,
                    x_return_status      => x_return_status,
                    x_return_message     => x_return_message);
     put_log ('Completing Extension of Periods and group Dates');

     l_default := 'N';
     BEGIN
       SELECT 'Y'
       INTO l_default
       FROM DUAL
       WHERE  EXISTS (SELECT var_rent_id
                      FROM   pn_var_bkhd_defaults_all
                      WHERE var_rent_id   = main_vr_rec.var_rent_id);
       EXCEPTION
         WHEN OTHERS THEN
           l_default := 'N';
     END;

     put_log ('Defaults Exists:'||l_default);
     IF l_default = 'Y' THEN
       UPDATE pn_var_line_defaults_all
       SET line_end_date  = p_extension_end_date,
           processed_flag = 0
       WHERE var_rent_id = main_vr_rec.var_rent_id
       AND line_end_date = p_old_end_date;
       COMMIT;
     END IF;
   END LOOP;
   put_log ('PN_VAR_RENT_PKG.create_new_bkpts (-)');
   EXCEPTION
     WHEN OTHERS THEN
       pnp_debug_pkg.debug('error ' || sqlerrm);
       fnd_message.set_name('PN','PN_OTHERS_EXCEPTION');
       fnd_message.set_token('ERR_MSG',sqlerrm);
       x_return_status := FND_API.G_RET_STS_ERROR;
       pnp_debug_pkg.debug (fnd_message.get);
       pnp_debug_pkg.put_log_msg (fnd_message.get);
 END create_new_bkpts;


FUNCTION GET_PRORATION_RULE(p_var_rent_id IN NUMBER DEFAULT NULL,
                            p_period_id   IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
   CURSOR var_rent_cur IS
   SELECT a.proration_rule
   FROM   pn_var_rents_all a,
          pn_var_periods_all b
   WHERE  a.var_rent_id = NVL(p_var_rent_id,a.var_rent_id)
   AND    a.var_rent_id = b.var_rent_id
   AND    b.period_id = NVL(p_period_id,b.period_id);

   l_proration_rule VARCHAR2(50) := NULL;
BEGIN

  IF p_var_rent_id IS NOT NULL THEN
    BEGIN
      SELECT proration_rule
      INTO l_proration_rule
      FROM pn_var_rents_all
      WHERE var_rent_id = p_var_rent_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_proration_rule := NULL;
    END;

  ELSE
    BEGIN
      SELECT proration_rule
      INTO l_proration_rule
      FROM   pn_var_rents_all a,
             pn_var_periods_all b
      WHERE  a.var_rent_id = b.var_rent_id
      AND    b.period_id = NVL(p_period_id,b.period_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_proration_rule := NULL;
    END;

  END IF;


  FOR  var_rent_rec in var_rent_cur LOOP
    l_proration_rule := var_rent_rec.proration_rule;
    EXIT;
  END LOOP;
  RETURN l_proration_rule;
END;

PROCEDURE generate_cal_periods_tbl(p_var_rent_dates_rec IN PN_VAR_RENT_DATES_ALL%ROWTYPE,
                                   p_start_date         IN DATE,
                                   p_end_date           IN DATE,
                                   p_extension_end_date IN DATE,
                                   x_cal_periods_tbl    OUT NOCOPY cal_periods_tbl)
IS
  CURSOR cal_periods_cur(p_period_set_name VARCHAR2,
                         p_period_type     VARCHAR2,
                         p_start_date      DATE,
                         p_end_date        DATE) IS
  SELECT MIN(start_date) start_date,
         MAX(end_date) end_date ,
         period_year
  FROM gl_periods
  WHERE period_set_name = p_period_set_name
  AND period_type       = p_period_type
  AND period_year       >= TO_NUMBER(TO_CHAR(TO_DATE(p_end_date,'DD/MM/RRRR'),'RRRR'))
  AND period_year       <= TO_NUMBER(TO_CHAR(TO_DATE(p_extension_end_date,'DD/MM/RRRR'),'RRRR'))
  GROUP BY period_year;

  l_index                     NUMBER :=0;
  l_start_date                DATE ;
  l_end_date                  DATE ;
BEGIN
  pnp_debug_pkg.debug('generate_cal periodd(+)');
  pnp_debug_pkg.debug('use gl calendar' || p_var_rent_dates_rec.use_gl_calendar);
  IF NVL(p_var_rent_dates_rec.use_gl_calendar,'N') = 'Y' THEN
    FOR cal_periods_rec in cal_periods_cur(
                p_var_rent_dates_rec.gl_period_set_name,
                p_var_rent_dates_rec.period_type,
                p_start_date,
                nvl(p_extension_end_date,p_end_date))
    LOOP
      l_index := l_index + 1;
      x_cal_periods_tbl(l_index).period_year := cal_periods_rec.period_year;
      x_cal_periods_tbl(l_index).start_date := cal_periods_rec.start_date;
      x_cal_periods_tbl(l_index).end_date := cal_periods_rec.end_date ;
    END LOOP;
  ELSE
    l_start_date := p_start_date;
    pnp_debug_pkg.debug ('l_end_date' || l_end_date);
    pnp_debug_pkg.debug ('l_start_date' || l_start_date);
    l_end_date := ADD_MONTHS(p_var_rent_dates_rec.year_start_date , 12) - 1;
    WHILE  l_start_date < nvl(p_extension_end_date,p_end_date)
    LOOP
      l_index := l_index + 1;
      x_cal_periods_tbl(l_index).start_date := l_start_date;
      IF p_extension_end_date <= l_end_date THEN
        x_cal_periods_tbl(l_index).end_date := p_extension_end_date;
      ELSE
        x_cal_periods_tbl(l_index).end_date := l_end_date;
      END IF;
      l_start_date := l_end_date + 1;
      l_end_date := ADD_MONTHS(l_start_date , 12) - 1;
      pnp_debug_pkg.debug ('loop l_end_date' || l_end_date);
    END LOOP;
  END IF;
  -- end if of use_gl_calendar
END generate_cal_periods_tbl;

PROCEDURE generate_group_inv_tbl ( p_pn_var_rent_dates_rec IN pn_var_rent_dates_all%rowtype,
                                   p_period_start_date  IN DATE,
                                   p_period_end_date    IN DATE,
                                   x_group_dates_tbl    OUT NOCOPY group_dates_tbl,
                                   x_inv_dates_tbl      OUT NOCOPY group_dates_tbl)

IS
    l_index             NUMBER := 0;
    l_grpDateId         NUMBER := NULL;
    l_rptg_date         DATE ;
    l_year_st_date      DATE ;
    l_year_end_date     DATE ;
    l_grp_st_date       DATE ;
    l_grp_end_date      DATE ;
    l_inv_st_date       DATE ;
    l_inv_end_date      DATE ;

   CURSOR group_date_mon(p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT   min(start_date) start_date,  max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date        >= p_vr_comm_date
   AND      period_type = p_pn_var_rent_dates_rec.period_type
   AND      adjustment_period_flag = 'N'
   GROUP BY period_year, quarter_num, period_num
   ORDER BY start_date,end_date;

   CURSOR group_date_qtr(p_vr_comm_date DATE, p_vr_term_date DATE)IS
   SELECT   min(start_date) start_date,  max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date      >= p_vr_comm_date
   AND      quarter_num     IN(1,2,3,4)
   AND      period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY period_year, quarter_num
   ORDER BY start_date;

   CURSOR group_date_sa (p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT   min(g1.start_date) start_date
              ,max(g2.end_date) end_date
   FROM     gl_periods g1, gl_periods g2
   WHERE    g1.period_set_name(+) = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g2.period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g1.start_date(+)     <= p_vr_term_date
   AND      g2.end_date        >=  p_vr_comm_date
   AND      g1.quarter_num(+) = 1
   AND      g2.quarter_num = 2
   AND      g1.period_year(+) = g2.period_year
   AND      g1.start_date IS NOT NULL
   AND      g2.end_date IS NOT NULL
   AND      g1.period_type = p_pn_var_rent_dates_rec.period_type
   AND      g2.period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY g2.period_year
   UNION
   SELECT   min(g1.start_date) start_date
            ,max(g2.end_date) end_date
   FROM     gl_periods g1, gl_periods g2
   WHERE    g1.period_set_name(+) = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g2.period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      g1.start_date(+)     <= p_vr_term_date
   AND      g2.end_date        >=  p_vr_comm_date
   AND      g1.quarter_num(+) = 3
   AND      g2.quarter_num = 4
   AND      g1.period_year (+)= g2.period_year
   AND      g1.start_date IS NOT NULL
   AND      g2.end_date IS NOT NULL
   AND      g1.period_type = p_pn_var_rent_dates_rec.period_type
   AND      g2.period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY g2.period_year
   order by 1;

   CURSOR group_date_ann (p_vr_comm_date DATE, p_vr_term_date DATE) IS
   SELECT min(start_date) start_date,max(end_date) end_date
   FROM     gl_periods
   WHERE    period_set_name = p_pn_var_rent_dates_rec.gl_period_set_name
   AND      start_date      <= p_vr_term_date
   AND      end_date        >= p_vr_comm_date
   AND    period_type = p_pn_var_rent_dates_rec.period_type
   GROUP BY period_year
   ORDER BY start_date;


BEGIN

   l_index := 0;
   IF NVL(p_pn_var_rent_dates_rec.use_gl_calendar,'N') = 'Y' THEN
      IF p_pn_var_rent_dates_rec.reptg_freq_code = 'MON' THEN
         FOR group_date_rec in group_date_mon(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_group_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_group_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'QTR' THEN
        pnp_debug_pkg.debug('reporting = quarter');
         FOR group_date_rec in group_date_qtr(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_group_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_group_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'SA' THEN
         FOR group_date_rec in group_date_sa(p_period_start_date,
                                             p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_group_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_group_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'YR' THEN
         FOR group_date_rec in group_date_ann(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_group_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_group_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      END IF;

      -- determine invoice periods
      l_index := 0;
      IF p_pn_var_rent_dates_rec.invg_freq_code = 'MON' THEN
         FOR group_date_rec in group_date_mon(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_inv_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_inv_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'QTR' THEN
         FOR group_date_rec in group_date_qtr(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_inv_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_inv_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'SA' THEN
         FOR group_date_rec in group_date_sa(p_period_start_date,
                                             p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_inv_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_inv_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'YR' THEN
         FOR group_date_rec in group_date_ann(p_period_start_date,
                                              p_period_end_date)
         LOOP
            l_index := l_index + 1;
            x_inv_dates_tbl(l_index).start_date := group_date_rec.start_date;
            x_inv_dates_tbl(l_index).end_date := group_date_rec.end_date;
         END LOOP;
      END IF;
   ELSE
     -- use_gl_calendar = N

     l_year_st_date := p_pn_var_rent_dates_rec.year_start_date;
     l_year_end_date := ADD_MONTHS(l_year_st_date,12);
     l_grp_st_date := l_year_st_date;
     l_grp_end_date := l_year_st_date;
     l_inv_st_date := l_year_st_date;
     l_inv_end_date := l_year_st_date;

     l_index := 0;
     WHILE l_grp_end_date < l_year_end_date LOOP
        l_index := l_index + 1;
        IF p_pn_var_rent_dates_rec.reptg_freq_code = 'MON' THEN
           l_grp_end_date := ADD_MONTHS(l_grp_st_date,1);
           x_group_dates_tbl(l_index).start_date := l_grp_st_date;
           x_group_dates_tbl(l_index).end_date := l_grp_end_date;
           l_grp_st_date := l_grp_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'QTR' THEN
           l_grp_end_date := ADD_MONTHS(l_grp_st_date,3);
           x_group_dates_tbl(l_index).start_date := l_grp_st_date;
           x_group_dates_tbl(l_index).end_date := l_grp_end_date;
           l_grp_st_date := l_grp_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'SA' THEN
           l_grp_end_date := ADD_MONTHS(l_grp_st_date,6);
           x_group_dates_tbl(l_index).start_date := l_grp_st_date;
           x_group_dates_tbl(l_index).end_date := l_grp_end_date;
           l_grp_st_date := l_grp_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.reptg_freq_code = 'YR' THEN
           l_grp_end_date := ADD_MONTHS(l_grp_st_date,12);
           x_group_dates_tbl(l_index).start_date := l_grp_st_date;
           x_group_dates_tbl(l_index).end_date := l_grp_end_date;
           l_grp_st_date := l_grp_end_date + 1;
        END IF;
        -- end if of reptg freq code
     END LOOP;
     -- end loop while reptg

     l_index := 0;
     WHILE l_inv_end_date < l_year_end_date LOOP

        IF p_pn_var_rent_dates_rec.invg_freq_code = 'MON' THEN
           l_inv_end_date := ADD_MONTHS(l_inv_st_date,1);
           x_inv_dates_tbl(l_index).start_date := l_inv_st_date;
           x_inv_dates_tbl(l_index).end_date := l_inv_end_date;
           l_inv_st_date := l_inv_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'QTR' THEN
           l_inv_end_date := ADD_MONTHS(l_inv_st_date,3);
           x_inv_dates_tbl(l_index).start_date := l_inv_st_date;
           x_inv_dates_tbl(l_index).end_date := l_inv_end_date;
           l_inv_st_date := l_inv_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'SA' THEN
           l_inv_end_date := ADD_MONTHS(l_inv_st_date,6);
           x_inv_dates_tbl(l_index).start_date := l_inv_st_date;
           x_inv_dates_tbl(l_index).end_date := l_inv_end_date;
           l_inv_st_date := l_inv_end_date + 1;
        ELSIF p_pn_var_rent_dates_rec.invg_freq_code = 'YR' THEN
           l_inv_end_date := ADD_MONTHS(l_inv_st_date,12);
           x_inv_dates_tbl(l_index).start_date := l_inv_st_date;
           x_inv_dates_tbl(l_index).end_date := l_inv_end_date;
           l_inv_st_date := l_inv_end_date + 1;
        END IF;

     END LOOP;
     -- end loop while invg

   END IF;
   -- end if of gl_calendar = Y

END generate_group_inv_tbl;


FUNCTION exists_bkpt_dtldateintersect ( p_var_rent_id IN NUMBER,
                                        p_line_default_id IN NUMBER,
                                        p_start_date   IN DATE,
                                        p_end_date     IN DATE)
RETURN BOOLEAN
IS

   CURSOR c_1 IS
   SELECT 'z'
   FROM DUAL
   WHERE EXISTS ( SELECT a.var_rent_id
                  FROM   pn_var_bkdt_defaults_all a,
                         pn_var_bkhd_defaults_all b
                  WHERE  a.var_rent_id = p_var_rent_id
                  AND    a.bkhd_default_id = b.bkhd_default_id
                  AND    b.line_default_id =  p_line_default_id
                  AND    ( (bkdt_start_date  < p_start_date AND
                           bkdt_end_date > p_end_date) OR
                           (bkdt_start_date < p_end_date AND
                            bkdt_end_date > p_end_date))) ;

BEGIN

   FOR c_rec in c_1 LOOP
      RETURN TRUE;
   END LOOP;

   RETURN FALSE;
END exists_bkpt_dtldateintersect;

PROCEDURE check_continious_def_dates ( p_var_rent_id IN NUMBER,
                                  p_line_default_id IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date   IN DATE,
                                  x_return_status OUT NOCOPY BOOLEAN,
                                  x_return_message OUT NOCOPY VARCHAR2,
                                  x_date1 OUT NOCOPY DATE,
                                  x_date2 OUT NOCOPY DATE)
IS



   CURSOR header_cur IS
   SELECT bkhd_default_id,
          bkhd_start_date,
          bkhd_end_date
  FROM    pn_var_bkhd_defaults_all
  WHERE   var_rent_id = p_var_rent_id
  AND     line_default_id = p_line_default_id
  ORDER BY bkhd_start_date;


  CURSOR exist_next_header_date (p_end_date DATE) IS
  SELECT 'x'
  FROM   dual
  WHERE  EXISTS ( SELECT var_Rent_id
                  FROM   pn_var_bkhd_defaults_all
                  WHERE  var_rent_id = p_var_rent_id
                  AND    line_default_id = p_line_default_id
                  AND    bkhd_start_date = p_end_date + 1);

   CURSOR detail_cur (p_header_id NUMBER) IS
   SELECT
          bkdt_start_date,
          bkdt_end_date
  FROM    pn_var_bkdt_defaults_all
  WHERE   var_rent_id = p_var_rent_id
  AND     bkhd_default_id = p_header_id
  ORDER BY bkdt_start_date;

  CURSOR exist_next_detail_date (p_header_id NUMBER,p_end_date DATE) IS
  SELECT 'x'
  FROM   dual
  WHERE  EXISTS ( SELECT var_Rent_id
                  FROM   pn_var_bkdt_defaults_all
                  WHERE  var_rent_id = p_var_rent_id
                  AND    bkhd_default_id = p_header_id
                  AND    bkdt_start_date = p_end_date + 1);

  l_dummy VARCHAR2(1) ;
BEGIN

   pnp_debug_pkg.debug('p_var_rent_id = '|| p_var_rent_id);
   pnp_debug_pkg.debug('p_line_default_id  =' || p_line_default_id);
   pnp_debug_pkg.debug('p_start_date = '|| p_start_date);
   pnp_debug_pkg.debug('p_end_date = '|| p_end_date);
   pnp_debug_pkg.debug(' char p_end_date = '|| to_char(p_end_date,'MM/DD/YYYY'));
   pnp_debug_pkg.debug(' RR p_end_date = '|| to_char(p_end_date,'MM/DD/RRRR'));

   x_return_status := FALSE;
   FOR header_rec in header_cur LOOP


      pnp_debug_pkg.debug(' header_rec.bkhd_end_date = '|| to_char(header_rec.bkhd_end_date,'MM/DD/RRRR'));
      IF header_rec.bkhd_end_date = p_end_date THEN
         pnp_debug_pkg.debug('HEADER = TRUE');
         x_return_status := TRUE;
      ELSE
         l_dummy := NULL;
         OPEN exist_next_header_date ( header_rec.bkhd_end_date) ;
         FETCH exist_next_header_date INTO l_dummy;
         CLOSE exist_next_header_date;

         IF l_dummy IS NULL THEN
            x_return_status := FALSE;
            x_return_message := 'PN_VAR_BKHD_DEF_DATE_GAPS';
            EXIT;
         END IF;
      END IF;

      FOR detail_rec in detail_cur (header_rec.bkhd_default_id) LOOP
         pnp_debug_pkg.debug(' detail_rec.bkdt_end_date = '|| to_char(detail_rec.bkdt_end_date,'MM/DD/RRRR'));
         IF detail_rec.bkdt_end_date = header_rec.bkhd_end_date THEN
         pnp_debug_pkg.debug('DETAIL = TRUE');
            x_return_status := TRUE;
         ELSE
            l_dummy := NULL;
            OPEN exist_next_detail_date ( header_rec.bkhd_default_id,
                                          detail_rec.bkdt_end_date) ;
            FETCH exist_next_detail_date INTO l_dummy;
            CLOSE exist_next_detail_date;
            IF l_dummy IS NULL THEN
               x_return_status := FALSE;
               x_return_message := 'PN_VAR_BKDT_DEF_DATE_GAPS';
               x_date1 := header_rec.bkhd_start_date;
               x_date2 := header_rec.bkhd_end_date;
               EXIT;
            END IF;
         END IF;
      END LOOP; -- end loop for detail rec
   END LOOP; -- end loop for header rec


END;

PROCEDURE check_continious_def_dates ( p_var_rent_id IN NUMBER,
                                  p_line_item_id IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date   IN DATE,
                                  x_return_status OUT NOCOPY BOOLEAN,
                                  x_return_message OUT NOCOPY VARCHAR2,
                                  x_date1 OUT NOCOPY DATE,
                                  x_date2 OUT NOCOPY DATE)
IS

   l_filename                VARCHAR2(50) := 'CHECK'||to_char(sysdate,'MMDDYYHHMMSS');
   l_pathname                VARCHAR2(20) := '/usr/tmp/';


   CURSOR header_cur IS
   SELECT bkpt_header_id,
          bkhd_start_date,
          bkhd_end_date
  FROM    pn_var_bkpts_head_all
  WHERE   var_rent_id = p_var_rent_id
  AND     line_item_id = p_line_item_id
  ORDER BY bkhd_start_date;


  CURSOR exist_next_header_date (p_end_date DATE) IS
  SELECT 'x'
  FROM   dual
  WHERE  EXISTS ( SELECT var_Rent_id
                  FROM   pn_var_bkpts_head_all
                  WHERE  var_rent_id = p_var_rent_id
                  AND    line_item_id = p_line_item_id
                  AND    bkhd_start_date = p_end_date + 1);

   CURSOR detail_cur (p_header_id NUMBER) IS
   SELECT
          bkpt_start_date,
          bkpt_end_date
  FROM    pn_var_bkpts_det_all
  WHERE   var_rent_id = p_var_rent_id
  AND     bkpt_header_id = p_header_id
  ORDER BY bkpt_start_date;

  CURSOR exist_next_detail_date (p_header_id NUMBER,p_end_date DATE) IS
  SELECT 'x'
  FROM   dual
  WHERE  EXISTS ( SELECT var_Rent_id
                  FROM   pn_var_bkpts_det_all
                  WHERE  var_rent_id = p_var_rent_id
                  AND    bkpt_header_id = p_header_id
                  AND    bkpt_start_date = p_end_date + 1);

  l_dummy VARCHAR2(1) ;
BEGIN

   pnp_debug_pkg.debug('p_var_rent_id = '|| p_var_rent_id);
   pnp_debug_pkg.debug('p_line_item_id  =' || p_line_item_id);
   pnp_debug_pkg.debug('p_start_date = '|| p_start_date);
   pnp_debug_pkg.debug('p_end_date = '|| p_end_date);
   pnp_debug_pkg.debug(' char p_end_date = '|| to_char(p_end_date,'MM/DD/YYYY'));
   pnp_debug_pkg.debug(' RR p_end_date = '|| to_char(p_end_date,'MM/DD/RRRR'));

   x_return_status := FALSE;
   FOR header_rec in header_cur LOOP


      pnp_debug_pkg.debug(' header_rec.bkhd_end_date = '|| to_char(header_rec.bkhd_end_date,'MM/DD/RRRR'));
      IF header_rec.bkhd_end_date = p_end_date THEN
         pnp_debug_pkg.debug('HEADER = TRUE');
         x_return_status := TRUE;
      ELSE
         l_dummy := NULL;
         OPEN exist_next_header_date ( header_rec.bkhd_end_date) ;
         FETCH exist_next_header_date INTO l_dummy;
         CLOSE exist_next_header_date;

         IF l_dummy IS NULL THEN
            x_return_status := FALSE;
            x_return_message := 'PN_VAR_BKHD_DEF_DATE_GAPS';
            EXIT;
         END IF;
      END IF;

      FOR detail_rec in detail_cur (header_rec.bkpt_header_id) LOOP
         pnp_debug_pkg.debug(' detail_rec.bkpt_end_date = '|| to_char(detail_rec.bkpt_end_date,'MM/DD/RRRR'));
         IF detail_rec.bkpt_end_Date = header_rec.bkhd_end_date THEN
         pnp_debug_pkg.debug('DETAIL = TRUE');
            x_return_status := TRUE;
         ELSE
            l_dummy := NULL;
            OPEN exist_next_detail_date ( header_rec.bkpt_header_id,
                                          detail_rec.bkpt_end_date) ;
            FETCH exist_next_detail_date INTO l_dummy;
            CLOSE exist_next_detail_date;
            IF l_dummy IS NULL THEN
               x_return_status := FALSE;
               x_return_message := 'PN_VAR_BKDT_DEF_DATE_GAPS';
               x_date1 := header_rec.bkhd_start_date;
               x_date2 := header_rec.bkhd_end_date;
               EXIT;
            END IF;
         END IF;
      END LOOP; -- end loop for detail rec
   END LOOP; -- end loop for header rec


END;




FUNCTION is_template_used ( p_template_id IN NUMBER)
RETURN BOOLEAN
IS

   CURSOR var_rent_cur IS
   SELECT 'x'
   FROM   dual
   WHERE EXISTS ( SELECT var_rent_id
                  FROM pn_var_rents_all
                  WHERE  agreement_template_id = p_template_id);

   l_return BOOLEAN := FALSE;
BEGIN

  For c_rec in var_rent_cur
  LOOP

    l_return := TRUE;
    EXIT;
  END LOOP;

  RETURN l_return;

END ;


-- Function returs true if we have generated
-- setup infomration like ytd /annual/prorated bkpts.


FUNCTION FIND_IF_BKPTS_SETUP_EXISTS  (p_var_rent_id NUMBER)
RETURN BOOLEAN IS

      l_bkpts_exists   NUMBER;

   BEGIN

        pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTS_SETUP_EXISTS (+)');

      /*SELECT 1
      INTO   l_bkpts_exists
      FROM   dual
      WHERE  EXISTS ( SELECT 1
                      FROM   pn_var_transactions_all
                      WHERE  var_rent_id = p_var_rent_id);

      IF l_bkpts_exists is NOT NULL THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;*/
      NULL;


   EXCEPTION

      WHEN OTHERS
  THEN
     RETURN FALSE;

        pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_BKPTS_SETUP_EXISTS (-)');

END FIND_IF_BKPTS_SETUP_EXISTS;

Procedure put_log(p_string VARCHAR2)
IS
BEGIN

pnp_debug_pkg.debug(p_string);
pnp_debug_pkg.put_log_msg(p_string);

END;
-- M2M End

FUNCTION is_partial_period (p_period_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR  is_partial_period_cur IS
    SELECT partial_period
    FROM   pn_var_periods_all
    WHERE  period_id = p_period_id;
  l_return VARCHAR2(1) := 'X';
BEGIN
  OPEN is_partial_period_cur;
  FETCH is_partial_period_cur INTO l_return;
  IF is_partial_period_cur%NOTFOUND THEN
     CLOSE is_partial_period_cur;
     pnp_debug_pkg.debug('Cursor is_partial_period_cur NO_DATA_FOUND');
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE is_partial_period_cur;
  RETURN l_return;
END is_partial_period;

/*===========================================================================+
 | PROCEDURE
 |    DETERMINE_FREQUENCY
 |
 | DESCRIPTION
 |    Determines frequency to be chosen for REPTG and INVG for 'No Proration'
 |    calculation method
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_START_DATE
 |                    X_VAR_RENT_END_DATE
 |
 |              OUT:
 |                    X_FREQUENCY_CODE
 |
 | RETURNS    : None
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |     30-JAN-2004  Daniel Thota  o Created
 +===========================================================================*/
FUNCTION DETERMINE_FREQUENCY (
  X_VAR_RENT_START_DATE IN PN_VAR_RENTS_ALL.COMMENCEMENT_DATE%TYPE
  ,X_VAR_RENT_END_DATE  IN PN_VAR_RENTS_ALL.TERMINATION_DATE%TYPE
) RETURN PN_VAR_RENT_DATES_ALL.REPTG_FREQ_CODE%TYPE
is

       l_days       NUMBER;
       l_freq_code  PN_VAR_RENT_DATES_ALL.REPTG_FREQ_CODE%TYPE;

BEGIN

        pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DETERMINE_FREQUENCY (+)');

    SELECT X_VAR_RENT_END_DATE - X_VAR_RENT_START_DATE + 1
    INTO   l_days
    FROM   dual;

    IF l_days > 0 AND l_days <= 31 THEN
       l_freq_code := 'MON';
    ELSIF l_days > 31 AND l_days <= 92 THEN
       l_freq_code := 'QTR';
    ELSIF l_days > 92 AND l_days <= 184 THEN
       l_freq_code := 'SA';
    ELSIF l_days > 184 AND l_days <= 366 THEN
       l_freq_code := 'YR';
    ELSE l_freq_code := NULL;
    END IF;

    RETURN l_freq_code;

   EXCEPTION

      WHEN OTHERS
  THEN
     RETURN NULL;

        pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.DETERMINE_FREQUENCY (-)');

END DETERMINE_FREQUENCY;

PROCEDURE update_bkpt_details(p_var_rent_id     IN NUMBER,
                              p_bkdt_dflt_id    IN NUMBER,
                              p_bkpt_rate       IN NUMBER)
IS
BEGIN

  UPDATE pn_var_bkpts_det_all
  SET bkpt_rate     = p_bkpt_rate
  WHERE var_rent_id = p_var_rent_id
  AND bkdt_default_id = p_bkdt_dflt_id;

  PN_VAR_CHG_CAL_PKG.POPULATE_TRANSACTIONS(p_var_rent_id        => p_var_rent_id);

END update_bkpt_details;

PROCEDURE change_stratified_rows(p_bkhd_default_id      IN NUMBER,
                                 p_bkdt_st_date_old     IN DATE,
                                 p_bkdt_end_date_old    IN DATE,
                                 p_bkdt_default_id      IN NUMBER,
                                 p_bkdt_st_date         IN DATE,
                                 p_bkdt_end_date        IN DATE)
IS
BEGIN

  Update pn_var_bkdt_defaults_all
  SET bkdt_start_date = p_bkdt_st_date,
      bkdt_end_date   = p_bkdt_end_date
  where bkhd_default_id = p_bkhd_default_id
  and bkdt_start_date   = p_bkdt_st_date_old
  and bkdt_end_date     = p_bkdt_end_date_old
  and bkdt_default_id   <> p_bkdt_default_id;

END change_stratified_rows;

-------------------------------------------------------------------------------
--  NAME         : delete_vr_setup
--  DESCRIPTION  : This procedure deletes all the set up data for dates >
--                 new termination date e.g breakpoint records, volume history
--                 etc
--  PURPOSE      :
--  INVOKED FROM : process_vr_early_term
--  ARGUMENTS    : IN :  p_var_rent_id, p_new_termn_date
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  20-MAR-07   lbala     o Added code to delete from pn_var_abat_defaults_all
-------------------------------------------------------------------------------
PROCEDURE delete_vr_setup ( p_var_rent_id    IN NUMBER
                           ,p_new_termn_date IN DATE)
IS
BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.delete_vr_setup (+)');

   /* Delete the data from main tables */
   DELETE pn_var_vol_hist_all
   WHERE start_date   > p_new_termn_date
   AND period_id IN (SELECT period_id
                     FROM pn_var_periods_all
                     WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_bkpts_det_all
   WHERE bkpt_start_date > p_new_termn_date
   AND   var_rent_id = p_var_rent_id;

   DELETE pn_var_bkpts_head_all
   WHERE bkhd_start_date > p_new_termn_date
   AND   var_rent_id = p_var_rent_id;

   DELETE pn_var_deductions_all
   WHERE start_date > p_new_termn_date
   AND period_id IN (SELECT period_id
                     FROM pn_var_periods_all
                     WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_rent_summ_all
   WHERE grp_date_id IN (SELECT grp_date_id
                         FROM pn_var_grp_dates_all
                         WHERE var_rent_id = p_var_rent_id
                         AND grp_start_date > p_new_termn_date);

   DELETE pn_var_constraints_all
   WHERE constr_start_date   > p_new_termn_date
   AND   period_id IN (SELECT period_id
                       FROM pn_var_periods_all
                       WHERE var_rent_id = p_var_rent_id);


   DELETE pn_var_lines_all
   WHERE period_id IN (SELECT period_id
                       FROM pn_var_periods_all
                       WHERE var_rent_id = p_var_rent_id
                       AND start_date > p_new_termn_date);

   /* Delete data from defaults table */

   DELETE pn_var_bkdt_defaults_all
   WHERE var_rent_id = p_var_rent_id
   AND bkdt_start_date > p_new_termn_date;

   DELETE pn_var_bkhd_defaults_all
   WHERE var_rent_id = p_var_rent_id
   AND bkhd_start_date > p_new_termn_date;

   DELETE pn_var_line_defaults_all
   WHERE line_start_date >= p_new_termn_date
   AND var_rent_id = p_var_rent_id;

   DELETE pn_var_constr_defaults_all
   WHERE constr_start_date   > p_new_termn_date
   AND var_rent_id = p_var_rent_id;

   DELETE pn_var_abat_defaults_all
   WHERE start_date > p_new_termn_date
   AND var_rent_id = p_var_rent_id;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.delete_vr_setup (-)');

END delete_vr_setup;

-------------------------------------------------------------------------------
--  NAME         : remove_later_periods
--  DESCRIPTION  : This procedure process periods which start after the new
--                 termination date
--  PURPOSE      :
--  INVOKED FROM : process_vr_early_term
--  ARGUMENTS    : IN :  p_var_rent_id, p_new_termn_date, p_old_termn_date
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  03-DEC-07   acprakas  o Bug#6490896. Modified to avoid auto creation of payment/billing terms
--  21-JUL-08   acprakas  o Bug#6524437. Modified cursors invoice_cur, term_status_cur,
--                          max_adjust_num_cur, actual_invoice_amount to pick up true up term invoices
--                          also for reversing.
-------------------------------------------------------------------------------
PROCEDURE remove_later_periods (  p_var_rent_id    IN NUMBER
                                , p_new_termn_date IN DATE
                                , p_old_termn_date IN DATE
                                , x_return_status  OUT NOCOPY VARCHAR2
                                , x_return_message OUT NOCOPY VARCHAR2)
IS

   /* This cursor fetches the distinct invoices for periods starting after new termination date */
   CURSOR invoice_date_cur  IS
      SELECT  DISTINCT pvi.invoice_date, pvi.period_id
      FROM   pn_var_rent_inv_all pvi, pn_var_periods_all pvp
      WHERE  pvp.period_id = pvi.period_id
      AND    pvp.start_date > p_new_termn_date
      AND    pvp.var_rent_id = p_var_rent_id;

   /* This cursor fetches the invoices, which are not deleted, for the
      periods starting after new termination date */
   CURSOR rent_inv_cur ( p_period_id    NUMBER
                        ,p_invoice_date DATE
                        ,p_adjust_num   NUMBER) IS
      SELECT  *
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND   (NVL(actual_exp_code, 'N') = 'Y' OR
             NVL(variance_exp_code, 'N') = 'Y' OR
             NVL(forecasted_exp_code, 'N') = 'Y' OR
	     NVL(true_up_exp_code,'N') = 'Y')
      /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
      AND    invoice_date = p_invoice_date
      AND    adjust_num = p_adjust_num;
/*Bug#6524437
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;
*/

   /* This cursor fetches the invoices, which are not deleted, for the
      periods starting after new termination date */
   CURSOR term_status_cur ( p_period_id    NUMBER
                           ,p_invoice_date DATE
                           ,p_adjust_num   NUMBER) IS
      SELECT  variance_exp_code, forecasted_exp_code
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND   (NVL(actual_exp_code, 'N') = 'Y' OR
             NVL(variance_exp_code, 'N') = 'Y' OR
             NVL(forecasted_exp_code, 'N') = 'Y' OR
	     NVL(true_up_exp_code,'N') = 'Y')
      /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
      AND    invoice_date = p_invoice_date
      AND    adjust_num = p_adjust_num;

      /*Bug#6524437
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;
      */

   /* This cursor fetches periods starting after new termination date in descending order of start date */
   CURSOR period_cur IS
      SELECT period_id
      FROM pn_var_periods_all
      WHERE var_rent_id = p_var_rent_id
      AND start_date > p_new_termn_date
      ORDER BY start_date DESC;

   /* this cursor fetches invoice for a particular period */
   CURSOR invoice_cur (p_period_id NUMBER) IS
      SELECT var_rent_inv_id
      FROM pn_var_rent_inv_all
      WHERE period_id = p_period_id;

   /* This cursor fetches periods staring after new termination date for which there exists invoices */
   CURSOR period_inv_cur IS
      SELECT period_id
      FROM pn_var_periods_all per
      WHERE per.var_rent_id = p_var_rent_id
      AND per.start_date > p_new_termn_date
      AND EXISTS (SELECT var_rent_inv_id
                  FROM pn_var_rent_inv_all
                  WHERE period_id = per.period_id);

      /* Fetches payment term information for a invoice id */
   CURSOR payment_cur(p_invoice_date DATE) IS
      SELECT payment_term_id
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id IN (SELECT var_rent_inv_id
                                FROM pn_var_rent_inv_all
                                WHERE invoice_date = p_invoice_date
                                AND var_rent_id = p_var_rent_id);

   /* Fetches the maximum adjust num cursor */
   CURSOR max_adjust_num_cur (p_period_id NUMBER,
                              p_invoice_date DATE) IS
      SELECT max(adjust_num) max_adjust_num
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND    invoice_date = p_invoice_date;

      /*Bug#6524437
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;
      */

   /* Fetches the amount for the particular invoice date */
   CURSOR actual_invoice_amount (p_period_id NUMBER,
                                 p_invoice_date DATE) IS
      SELECT SUM(actual_invoiced_amount) actual_amount
      FROM   pn_var_rent_inv_all
      WHERE var_rent_inv_id IN ( SELECT var_rent_inv_id
                                 FROM   pn_var_rent_inv_all
                                 WHERE  period_id = p_period_id
                                 AND    (NVL(actual_exp_code, 'N') = 'Y' OR
                                         NVL(variance_exp_code, 'N') = 'Y'  OR
                                         NVL(forecasted_exp_code, 'N') = 'Y' OR
				         NVL(true_up_exp_code, 'N') = 'Y')
                                 /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
                                 AND    invoice_date = p_invoice_date);

   l_invoice_exists VARCHAR2(1) := 'N';
   l_actual_invoiced_amount   pn_var_rent_inv_all.actual_invoiced_amount%TYPE;
   l_rowid              ROWID;
   l_var_rent_inv_id    NUMBER;
   l_date               DATE := SYSDATE;
   l_errbuf             VARCHAR2(250) := NULL;
   l_retcode            VARCHAR2(250);
   l_max_adjust_num      NUMBER := 0;
   l_forecasted_exp_code VARCHAR2(1) := 'N';
   l_variance_exp_code   VARCHAR2(1) := 'N';
   l_var_term_status     VARCHAR2(1);

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.remove_later_periods (+)');
   pnp_debug_pkg.debug ('  Parameters :');
   pnp_debug_pkg.debug ('  ------------------------------------------- :');
   pnp_debug_pkg.debug ('  p_var_rent_id         = '|| p_var_rent_id);
   pnp_debug_pkg.debug ('  p_new_termn_date      = '|| p_new_termn_date);
   pnp_debug_pkg.debug ('  p_old_termn_date      = '|| p_old_termn_date);
   pnp_debug_pkg.debug ('  ------------------------------------------- :');

   /* Delete draft terms for invoices for all periods which lie after the new termination date */
   DELETE pn_payment_terms_all
   WHERE status = 'DRAFT'
   AND   var_rent_inv_id   IN (SELECT var_rent_inv_id
                               FROM   pn_var_rent_inv_all pvi, pn_var_periods_all pvp
                               WHERE  pvi.period_id = pvp.period_id
                               AND    pvp.var_rent_id = p_var_rent_id
                               AND    pvp.start_date > p_new_termn_date);

   /* Delete invoices for which there are no terms */
   DELETE pn_var_rent_inv_all
   WHERE var_rent_inv_id NOT IN (SELECT ppt.var_rent_inv_id
                                 FROM pn_payment_terms_all ppt, pn_var_rent_inv_all pvi, pn_var_periods_all pvp
                                 WHERE ppt.var_rent_inv_id = pvi.var_rent_inv_id
                                 AND pvi.period_id = pvp.period_id
                                 AND   pvp.var_rent_id = p_var_rent_id
                                 AND   pvp.start_date > p_new_termn_date)
   AND var_rent_id = p_var_rent_id
   AND period_id IN (SELECT period_id
                     FROM pn_var_periods_all
                     WHERE var_rent_id = p_var_rent_id
                     AND start_date > p_new_termn_date);

   pnp_debug_pkg.debug ('Loop through the period which start after new termination date');
   /* Loop through the period which start after new termination date, starting from last and keep on deleting till you get a period which has an approved term associated with it */
   FOR period_rec IN period_cur LOOP

      pnp_debug_pkg.debug ('period id = '||period_rec.period_id);
      l_invoice_exists := 'N';

      /* Check if the period has an invoice associated with it */
      FOR invoice_rec IN invoice_cur (period_rec.period_id) LOOP
         pnp_debug_pkg.debug ('invoice exists ...');
         l_invoice_exists := 'Y';
      END LOOP;

      IF l_invoice_exists = 'Y' THEN
         /* If invoice exists in this period then exit from the loop as you need not delete any more periods */
         pnp_debug_pkg.debug ('exiting ...');
         EXIT;
      ELSE

         pnp_debug_pkg.debug ('deleting group date and periods  ...');
         /* Delete group dates and periods for which there exists no invoice */
         DELETE pn_var_grp_dates_all
         WHERE period_id = period_rec.period_id;

         DELETE pn_var_periods_all
         WHERE period_id = period_rec.period_id;
      END IF;

   END LOOP;

   pnp_debug_pkg.debug ('Loop through the invoices which are not deleted to create negative terms for each of the approved term ...');
   /* Loop through the invoices which are not deleted to create negative terms for each of the approved term */
   FOR invoice_date_rec IN invoice_date_cur LOOP

      FOR max_adjust_num_rec IN max_adjust_num_cur(invoice_date_rec.period_id, invoice_date_rec.invoice_date)
      LOOP
         l_max_adjust_num := max_adjust_num_rec.max_adjust_num;
      END LOOP;

      /* Fetch the total amount that needs to be invoiced */
      FOR rec IN actual_invoice_amount(invoice_date_rec.period_id, invoice_date_rec.invoice_date)  LOOP
         l_actual_invoiced_amount := rec.actual_amount;
      END LOOP;

       /* Fetch the term status for invoice with amx adjust number*/
      FOR term_status_rec IN term_status_cur(invoice_date_rec.period_id, invoice_date_rec.invoice_date, l_max_adjust_num)
      LOOP
         l_variance_exp_code := term_status_rec.variance_exp_code;
         l_forecasted_exp_code := term_status_rec.forecasted_exp_code;
      END LOOP;

      /* If the amount for reversal term is 0 , do not insert an invoice */
      IF l_actual_invoiced_amount <> 0 OR (l_variance_exp_code = 'N' AND l_forecasted_exp_code = 'Y' )THEN

         /* Loop for the invoice with amx adjust num for a aprticular invoice date */
         FOR rent_inv_rec IN rent_inv_cur(invoice_date_rec.period_id, invoice_date_rec.invoice_date, l_max_adjust_num )
         LOOP

       IF l_variance_exp_code = 'N' AND l_forecasted_exp_code = 'Y'
       THEN
               l_var_term_status := 'N';
       ELSE
               l_var_term_status := rent_inv_rec.variance_term_status;
       END IF;

            pnp_debug_pkg.debug ('Actual_invoiced_amount ...'||l_actual_invoiced_amount);
            pnp_debug_pkg.debug ('var rent inv id ...'||rent_inv_rec.var_rent_inv_id);

            /* Set var rent inv id to null before inserting a row */
            l_var_rent_inv_id := NULL;
            l_rowid           := NULL;


            pn_var_rent_inv_pkg.insert_row ( x_rowid                        => l_rowid,
                                             x_var_rent_inv_id              => l_var_rent_inv_id,
                                             x_adjust_num                   => l_max_adjust_num  + 1,
                                             x_invoice_date                 => rent_inv_rec.invoice_date,
                                             x_for_per_rent                 => rent_inv_rec.for_per_rent ,
                                             x_tot_act_vol                  => 0,
                                             x_act_per_rent                 => 0,
                                             x_constr_actual_rent           => 0,
                                             x_abatement_appl               => rent_inv_rec.abatement_appl,
                                             x_rec_abatement                => rent_inv_rec.rec_abatement,
                                             x_rec_abatement_override       => rent_inv_rec.rec_abatement_override,
                                             x_negative_rent                => rent_inv_rec.negative_rent ,
                                             x_actual_invoiced_amount       => -l_actual_invoiced_amount,
                                             x_period_id                    => rent_inv_rec.period_id,
                                             x_var_rent_id                  => p_var_rent_id,
                                             x_forecasted_term_status       => rent_inv_rec.forecasted_term_status,
                                             x_variance_term_status         => l_var_term_status,
                                             x_actual_term_status           => 'N', --rent_inv_rec.actual_term_status, --Bug#6490896
                                             x_forecasted_exp_code          => 'N',
                                             x_variance_exp_code            => 'N',
                                             x_actual_exp_code              => 'N',
                                             x_credit_flag                  => 'Y',
                                             x_comments                     => 'negative invoices',
                                             x_attribute_category           => rent_inv_rec.attribute_category,
                                             x_attribute1                   => rent_inv_rec.attribute1,
                                             x_attribute2                   => rent_inv_rec.attribute2,
                                             x_attribute3                   => rent_inv_rec.attribute3,
                                             x_attribute4                   => rent_inv_rec.attribute4,
                                             x_attribute5                   => rent_inv_rec.attribute5,
                                             x_attribute6                   => rent_inv_rec.attribute6,
                                             x_attribute7                   => rent_inv_rec.attribute7,
                                             x_attribute8                   => rent_inv_rec.attribute8,
                                             x_attribute9                   => rent_inv_rec.attribute9,
                                             x_attribute10                  => rent_inv_rec.attribute10,
                                             x_attribute11                  => rent_inv_rec.attribute11,
                                             x_attribute12                  => rent_inv_rec.attribute12,
                                             x_attribute13                  => rent_inv_rec.attribute13,
                                             x_attribute14                  => rent_inv_rec.attribute14,
                                             x_attribute15                  => rent_inv_rec.attribute15,
                                             x_creation_date                => l_date,
                                             x_created_by                   => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_date             => l_date,
                                             x_last_updated_by              => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_login            => nvl(fnd_profile.value('user_id'),1),
                                             x_true_up_amount               => rent_inv_rec.true_up_amt,
                                             x_true_up_status               => rent_inv_rec.true_up_status,
                                             x_true_up_exp_code             => rent_inv_rec.true_up_exp_code,
                                             x_org_id                       => rent_inv_rec.org_id);

            pnp_debug_pkg.debug ('l_var_rent_inv_id ...'||l_var_rent_inv_id);
            pnp_debug_pkg.debug ('For every period, call create_payment_term...'||rent_inv_rec.var_rent_inv_id);

/*
          FOR payment_rec IN payment_cur(invoice_date_rec.invoice_date) LOOP
               pn_variable_term_pkg.create_reversal_terms(p_payment_term_id => payment_rec.payment_term_id
                                                         ,p_var_rent_inv_id => l_var_rent_inv_id
                                                         ,p_var_rent_type   => 'ADJUSTMENT');
            END LOOP;
Bug#6490896 */
         END LOOP;

      END IF;

   END LOOP;

   /* OPEN ISSUE */
   /* Update the periods after new termination date - set status = 'Reversed'  */
   UPDATE pn_var_periods_all
   SET status = pn_var_rent_pkg.status
   WHERE var_rent_id = p_var_rent_id
   AND start_date > p_new_termn_date;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.remove_later_periods (-)');

EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.debug ('  Remove Later Periods Error:'||SQLERRM);
      x_return_status  := FND_API.G_RET_STS_ERROR;
      x_return_message := SQLERRM;

END remove_later_periods ;

-------------------------------------------------------------------------------
--  NAME         : early_terminate_setup
--  DESCRIPTION  : This procedure updates the end date of set up data for
--                 partial groups or periods
--  PURPOSE      :
--  INVOKED FROM : process_vr_early_term
--  ARGUMENTS    : IN :  p_var_rent_id, p_period_id, p_new_termn_date
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  11-JAN-07   Prabhakar o Added the call delete_report_date_row to delete
--                          the report records which fall after new termination date.
--  20-MAR-07   lbala     o Added code to update or delete pn_var_abat_defaults_all
--                          BUg # 5933345
-------------------------------------------------------------------------------
PROCEDURE early_terminate_setup (  p_var_rent_id    IN NUMBER
                                 , p_period_id      IN NUMBER
                                 , p_new_termn_date IN DATE)
IS

   /* Get the details of group dates */
   CURSOR var_rent_cur IS
      SELECT cal.reptg_day_of_month,
             cal.invg_day_of_month,
             cal.reptg_days_after,
             cal.invg_days_after,
             vr.cumulative_vol,
             DECODE(cal.reptg_freq_code, 'MON', 1,
                                     'QTR', 3,
                                     'SA', 6,
                                     'YR', 12,
                                     NULL) reptg_freq_code
      FROM   pn_var_rents_all vr, pn_var_rent_dates_all cal
      WHERE  vr.var_rent_id  = p_var_rent_id
      AND    cal.var_rent_id = vr.var_rent_id;

   /* Get the details of grp dates for group in which the new termination date falls */
   CURSOR grp_date_cur IS
      SELECT grp_start_date,
             grp_date_id,
             grp_end_date,
             inv_start_date,
             inv_end_date,
             group_date,
             invoice_date,
             period_id
      FROM  pn_var_grp_dates_all
      WHERE var_rent_id = p_var_rent_id
      AND p_new_termn_date BETWEEN grp_start_date AND grp_end_date;

   /* Get the details of breakpoint header default */
   CURSOR bkhd_default_cur IS
     SELECT bkhd_default_id
     FROM pn_var_bkhd_defaults_all
     WHERE var_rent_id = p_var_rent_id
     AND p_new_termn_date BETWEEN bkhd_start_date AND bkhd_end_date;

   /* Get the details of breakpoint details default */
   CURSOR bkdt_defaults_cur IS
     SELECT bkdt_default_id, bkhd_default_id
     FROM pn_var_bkdt_defaults_all
     WHERE var_rent_id = p_var_rent_id
     AND p_new_termn_date BETWEEN bkdt_start_date AND bkdt_end_date;

   /* Get the details of volume history */
   CURSOR vol_his_cur IS
     SELECT vol_hist_id, line_item_id
     FROM pn_var_vol_hist_all
     WHERE period_id = p_period_id
     AND p_new_termn_date BETWEEN start_date AND end_date;


   CURSOR bkpt_data_exists IS
      SELECT 'x' bkpt_exists
      FROM DUAL
      WHERE EXISTS (SELECT bkhd_default_id
                    FROM pn_var_bkpts_head_all
                    WHERE var_rent_id = p_var_rent_id
                    AND bkhd_default_id IS NOT NULL);

   /* Get the max invoice end date corresponding to the new termination date*/
  CURSOR inv_end_dt_cur(p_var_rent_id IN NUMBER) IS
   SELECT max(inv_end_date) inv_end_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    inv_end_date <= p_new_termn_date;

   l_reptg_day_of_month NUMBER   := 0;
   l_cumulative_vol     VARCHAR2(1) := 'Y';
   l_grp_start_date     DATE     := NULL;
   l_grp_end_date       DATE     := NULL;
   l_proration_factor   NUMBER   := 0;
   l_reptg_days_after   NUMBER   := 0;
   l_due_date           DATE     := NULL;
   l_group_date         DATE     := NULL;
   l_rept_freq          NUMBER   := 0;
   l_group_date_id      NUMBER   := NULL;
   l_inv_end_dt         DATE     := NULL;
   l_inv_start_dt       DATE     := NULL;
   l_invoice_date       DATE     := NULL;
   l_inv_sch_date       DATE     := NULL;
   l_period_id          NUMBER   := 0;

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.early_terminate_setup (+)');
   pnp_debug_pkg.debug ('p_var_rent_id ....'||p_var_rent_id);
   pnp_debug_pkg.debug ('p_period_id ......'||p_period_id);
   pnp_debug_pkg.debug ('p_new_termn_date ...'||p_new_termn_date);

   FOR rec IN vol_his_cur LOOP
      PN_VAR_VOL_HIST_PKG.MODIFY_ROW(  X_VOL_HIST_ID  => rec.vol_hist_id,
                                       X_LINE_ITEM_ID => rec.line_item_id,
                                       X_END_DATE     => p_new_termn_date);
   END LOOP;

   UPDATE pn_var_deductions_all
   SET end_date = p_new_termn_date
   WHERE period_id = p_period_id
   AND p_new_termn_date BETWEEN start_date AND end_date;

   FOR rec IN var_rent_cur LOOP
      l_reptg_day_of_month := rec.reptg_day_of_month;
      l_reptg_days_after   := rec.reptg_days_after;
      l_cumulative_vol     := rec.cumulative_vol;
      l_rept_freq          := rec.reptg_freq_code;
   END LOOP;

   FOR grp_date_rec IN grp_date_cur LOOP
      l_grp_start_date := grp_date_rec.grp_start_date;
      l_grp_end_date   := grp_date_rec.grp_end_date;
      l_group_date     := grp_date_rec.group_date;
      l_group_date_id  := grp_date_rec.grp_date_id;
      l_invoice_date   := grp_date_rec.invoice_date;
      l_period_id      := grp_date_rec.period_id;
      l_inv_start_dt   := grp_date_rec.inv_start_date;
      l_inv_end_dt     := grp_date_rec.inv_end_date;
   END LOOP;

   IF l_grp_end_date <> p_new_termn_date THEN

      l_proration_factor := ((p_new_termn_date - l_grp_start_date) + 1) /
                             ((LAST_DAY(ADD_MONTHS(LAST_DAY(l_group_date),l_rept_freq-1)) - l_group_date)+1);

      IF (l_reptg_day_of_month IS NOT NULL) THEN
         l_due_date  := (ADD_MONTHS(FIRST_DAY(p_new_termn_date),1)-1)+l_reptg_day_of_month;
      ELSE
         l_due_date  := p_new_termn_date + nvl(l_reptg_days_after,0);
      END IF;

      /*l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date( inv_start_date => l_invoice_date
                                                          ,vr_id => p_var_rent_id
                                                          ,p_period_id => l_period_id);*/

      UPDATE pn_var_grp_dates_all
      SET grp_end_date = p_new_termn_date,
          proration_factor = round(l_proration_factor,10),
          reptg_due_date = l_due_date
      WHERE var_rent_id = p_var_rent_id
      AND p_new_termn_date BETWEEN grp_start_date AND grp_end_date;

      PN_VAR_RENT_PKG.DELETE_REPORT_DATE_ROW(p_var_rent_id, p_new_termn_date);

      UPDATE pn_var_report_dates_all
      SET report_end_date = p_new_termn_date
      WHERE grp_date_id = l_group_date_id
      AND p_new_termn_date BETWEEN report_start_date AND report_end_date;

   END IF;

   l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date( inv_start_date => l_invoice_date
                                                       ,vr_id => p_var_rent_id
                                                       ,p_period_id => l_period_id);

   UPDATE pn_var_grp_dates_all
   SET inv_end_date = p_new_termn_date,
       inv_schedule_date = l_inv_sch_date
   WHERE var_rent_id = p_var_rent_id
   AND p_new_termn_date BETWEEN inv_start_date AND inv_end_date;

   UPDATE pn_var_constraints_all
   SET constr_end_date = p_new_termn_date
   WHERE period_id = p_period_id
   AND p_new_termn_date BETWEEN constr_start_date AND constr_end_date;

   /* Update the Breakpoint detail records in defaults */
   FOR bkdt_defaults_rec IN bkdt_defaults_cur LOOP
      pn_var_bkdt_defaults_pkg.modify_row (x_bkdt_default_id => bkdt_defaults_rec.bkdt_default_id,
                                           x_bkhd_default_id => bkdt_defaults_rec.bkhd_default_id,
                                           x_bkdt_end_date   => p_new_termn_date);
   END LOOP;

   /* Update the Breakpoint header records in defaults */
   FOR rec IN bkhd_default_cur LOOP
      pn_var_bkhd_defaults_pkg.modify_row (x_bkhd_default_id => rec.bkhd_default_id,
                                           x_bkhd_end_date   => p_new_termn_date);
   END LOOP;

   /* This generates line items, breakpoint header and details in main tables */

   FOR rec IN bkpt_data_exists LOOP
      DELETE FROM pn_var_bkpts_det_all
      WHERE var_rent_id = p_var_rent_id;

      DELETE FROM pn_var_bkpts_head_all
      WHERE var_rent_id = p_var_rent_id;

      pn_var_defaults_pkg.create_setup_data (x_var_rent_id => p_var_rent_id);
   END LOOP;

   UPDATE pn_var_constr_defaults_all
   SET constr_end_date = p_new_termn_date
   WHERE var_rent_id = p_var_rent_id
   AND p_new_termn_date BETWEEN constr_start_date AND constr_end_date;

   UPDATE pn_var_line_defaults_all
   SET line_end_date = p_new_termn_date
   WHERE var_rent_id = p_var_rent_id
   AND p_new_termn_date BETWEEN line_start_date AND line_end_date;

   /* Get max inv end date*/
   FOR inv_dt_rec IN inv_end_dt_cur(p_var_rent_id) LOOP
     l_inv_end_dt := inv_dt_rec.inv_end_date;
   END LOOP;

   /* Delete all abatements whose start date is after the new max inv end date
      since start and end dates of abatements must correspond to that of
      invoice periods */

   DELETE FROM pn_var_abat_defaults_all
   WHERE var_rent_id = p_var_rent_id
   AND p_new_termn_date BETWEEN start_date AND end_date
   AND start_date > l_inv_end_dt;

  /*Update all abatements so that their end date is the new max inv end date*/
   UPDATE pn_var_abat_defaults_all
   SET end_date = l_inv_end_dt
   WHERE var_rent_id = p_var_rent_id
   AND p_new_termn_date BETWEEN start_date AND end_date;

   UPDATE pn_var_periods_all
   SET end_date = p_new_termn_date,
       Partial_period = 'Y'
   WHERE var_rent_id = p_var_rent_id
   AND period_id = p_period_id;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.early_terminate_setup (-)');
END;

-------------------------------------------------------------------------------
--  NAME         : early_terminate_period
--  DESCRIPTION  : This procedure process period in which the new
--                 termination date lies.
--  PURPOSE      :
--  INVOKED FROM : process_vr_early_term
--  ARGUMENTS    : IN :  p_var_rent_id, p_period_id, p_new_termn_date,
--                       p_old_termn_date
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  03-DEC-07   acprakas  o Bug#6490896. Modified to avoid auto creation of payment/billing terms
-------------------------------------------------------------------------------
PROCEDURE early_terminate_period  ( p_var_rent_id    IN NUMBER
                                   ,p_period_id      IN NUMBER
                                   ,p_new_termn_date IN DATE
                                   ,p_old_termn_date IN DATE
                                   ,x_return_status  OUT NOCOPY VARCHAR2
                                   ,x_return_message  OUT NOCOPY VARCHAR2)
IS

   /* This cursor fetches the distinct invoices for periods starting after new termination date */
   CURSOR invoice_date_cur  IS
      SELECT  DISTINCT invoice_date
      FROM   pn_var_rent_inv_all
      WHERE period_id = p_period_id
      AND   invoice_date > p_new_termn_date;

   /* This cursor fetches the invoices existing after the new termination date */
   CURSOR invoice_cur ( p_period_id    NUMBER
                        ,p_invoice_date DATE
                        ,p_adjust_num   NUMBER)  IS
      SELECT  *
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND   (NVL(actual_exp_code, 'N') = 'Y' OR
             NVL(variance_exp_code, 'N') = 'Y' OR
        NVL(forecasted_exp_code, 'N') = 'Y')
      /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
      AND    invoice_date = p_invoice_date
      AND    adjust_num = p_adjust_num
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;

   /* This cursor fetches the invoices, which are not deleted, for the
      periods starting after new termination date */
   CURSOR term_status_cur ( p_period_id    NUMBER
                           ,p_invoice_date DATE
                           ,p_adjust_num   NUMBER) IS
      SELECT  variance_exp_code, forecasted_exp_code
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND   (NVL(actual_exp_code, 'N') = 'Y' OR
             NVL(variance_exp_code, 'N') = 'Y' OR
        NVL(forecasted_exp_code, 'N') = 'Y')
      /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
      AND    invoice_date = p_invoice_date
      AND    adjust_num = p_adjust_num
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;

      /* Fetches payment term information for a invoice id */
   CURSOR payment_cur(p_invoice_date DATE) IS
      SELECT payment_term_id
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id IN (SELECT var_rent_inv_id
                                FROM pn_var_rent_inv_all
                                WHERE invoice_date = p_invoice_date
                                AND var_rent_id = p_var_rent_id);

   /* Fetches the maximum adjust num cursor */
   CURSOR max_adjust_num_cur (p_period_id NUMBER,
                              p_invoice_date DATE) IS
      SELECT max(adjust_num) max_adjust_num
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND    invoice_date = p_invoice_date
      AND    true_up_amt IS NULL
      AND    true_up_status IS NULL
      AND    true_up_exp_code IS NULL;

   /* Fetches the amount for the particular invoice date */
   CURSOR actual_invoice_amount (p_period_id NUMBER,
                                 p_invoice_date DATE) IS
      SELECT SUM(actual_invoiced_amount) actual_amount
      FROM   pn_var_rent_inv_all
      WHERE var_rent_inv_id IN ( SELECT var_rent_inv_id
                                 FROM   pn_var_rent_inv_all
                                 WHERE  period_id = p_period_id
                                 AND    (NVL(actual_exp_code, 'N') = 'Y' OR
                                         NVL(variance_exp_code, 'N') = 'Y'  OR
                                    NVL(forecasted_exp_code, 'N') = 'Y')
                                 /*AND    NVL(actual_invoiced_amount, 0) <> 0*/
                                 AND    invoice_date = p_invoice_date);


   l_actual_invoiced_amount   pn_var_rent_inv_all.actual_invoiced_amount%TYPE;
   l_rowid              ROWID;
   l_var_rent_inv_id    NUMBER;
   l_date               DATE := SYSDATE;
   l_errbuf             VARCHAR2(250) := NULL;
   l_retcode            VARCHAR2(250);
   l_max_adjust_num     NUMBER := 0;
   l_forecasted_exp_code VARCHAR2(1) := 'N';
   l_variance_exp_code   VARCHAR2(1) := 'N';
   l_var_term_status     VARCHAR2(1);

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.early_terminate_period (+)');
   pnp_debug_pkg.debug ('p_var_rent_id ...'||p_var_rent_id);
   pnp_debug_pkg.debug ('p_period_id ....'||p_period_id);
   pnp_debug_pkg.debug ('p_new_termn_date ...'||p_new_termn_date);
   pnp_debug_pkg.debug ('p_old_termn_date ....'||p_old_termn_date);


   /* Delete draft terms for invoices for this period */
   DELETE pn_payment_terms_all
   WHERE status = 'DRAFT'
   AND   var_rent_inv_id IN (SELECT var_rent_inv_id
                             FROM   pn_var_rent_inv_all pvi, pn_var_periods_all pvp
                             WHERE pvi.period_id = p_period_id );

   /* Delete invoices for which there are no terms */
   DELETE pn_var_rent_inv_all
   WHERE  period_id = p_period_id
   AND   actual_exp_code = 'N'
   AND   forecasted_exp_code = 'N'
   AND   variance_exp_code = 'N';

   pnp_debug_pkg.debug ('p_old_termn_date ....'||p_old_termn_date);

   pnp_debug_pkg.debug ('Loop for invoices that start after new termination date for this period and create adjustment terms for them');
   /* Loop for invoices that start after new termination date for this period and create adjustment terms for them */
   FOR invoice_date_rec IN invoice_date_cur LOOP

      FOR max_adjust_num_rec IN max_adjust_num_cur(p_period_id, invoice_date_rec.invoice_date)
      LOOP
         l_max_adjust_num := max_adjust_num_rec.max_adjust_num;
      END LOOP;

      /* Fetch the total amount that needs to be invoiced */
      FOR rec IN actual_invoice_amount(p_period_id, invoice_date_rec.invoice_date)  LOOP
         l_actual_invoiced_amount := rec.actual_amount;
      END LOOP;

      /* Fetch the term status for invoice with amx adjust number*/
      FOR term_status_rec IN term_status_cur(p_period_id, invoice_date_rec.invoice_date, l_max_adjust_num)
      LOOP
         l_variance_exp_code := term_status_rec.variance_exp_code;
         l_forecasted_exp_code := term_status_rec.forecasted_exp_code;
      END LOOP;

      /* If the amount for reversal term is 0 , do not insert an invoice */
      IF l_actual_invoiced_amount <> 0 OR (l_variance_exp_code = 'N' AND l_forecasted_exp_code = 'Y' ) THEN

         /* Loop for the invoice with amx adjust num for a aprticular invoice date */
         FOR invoice_rec IN invoice_cur(p_period_id, invoice_date_rec.invoice_date, l_max_adjust_num )
         LOOP

       IF l_variance_exp_code = 'N' AND l_forecasted_exp_code = 'Y'
       THEN
               l_var_term_status := 'N';
       ELSE
               l_var_term_status := invoice_rec.variance_term_status;
       END IF;

            pnp_debug_pkg.debug ('Actual_invoiced_amount ...'||l_actual_invoiced_amount);
            pnp_debug_pkg.debug ('var rent inv id ...'||invoice_rec.var_rent_inv_id);
            /* Set var rent inv id to null before inserting a row */
            l_var_rent_inv_id := NULL;
            l_rowid           := NULL;

            pn_var_rent_inv_pkg.insert_row ( x_rowid                        => l_rowid,
                                             x_var_rent_inv_id              => l_var_rent_inv_id,
                                             x_adjust_num                   => l_max_adjust_num  + 1,
                                             x_invoice_date                 => invoice_rec.invoice_date,
                                             x_for_per_rent                 => invoice_rec.for_per_rent,
                                             x_tot_act_vol                  => 0,
                                             x_act_per_rent                 => 0,
                                             x_constr_actual_rent           => 0,
                                             x_abatement_appl               => invoice_rec.abatement_appl,
                                             x_rec_abatement                => invoice_rec.rec_abatement,
                                             x_rec_abatement_override       => invoice_rec.rec_abatement_override,
                                             x_negative_rent                => invoice_rec.negative_rent ,
                                             x_actual_invoiced_amount       => - l_actual_invoiced_amount,
                                             x_period_id                    => invoice_rec.period_id,
                                             x_var_rent_id                  => p_var_rent_id,
                                             x_forecasted_term_status       => invoice_rec.forecasted_term_status,
                                             x_variance_term_status         => l_var_term_status,
                                             x_actual_term_status           => 'N', --invoice_rec.actual_term_status, Bug#6490896
                                             x_forecasted_exp_code          => 'N',
                                             x_variance_exp_code            => 'N',
                                             x_actual_exp_code              => 'N',
                                             x_credit_flag                  => 'Y',
                                             x_comments                     => 'negative invoices',
                                             x_attribute_category           => invoice_rec.attribute_category,
                                             x_attribute1                   => invoice_rec.attribute1,
                                             x_attribute2                   => invoice_rec.attribute2,
                                             x_attribute3                   => invoice_rec.attribute3,
                                             x_attribute4                   => invoice_rec.attribute4,
                                             x_attribute5                   => invoice_rec.attribute5,
                                             x_attribute6                   => invoice_rec.attribute6,
                                             x_attribute7                   => invoice_rec.attribute7,
                                             x_attribute8                   => invoice_rec.attribute8,
                                             x_attribute9                   => invoice_rec.attribute9,
                                             x_attribute10                  => invoice_rec.attribute10,
                                             x_attribute11                  => invoice_rec.attribute11,
                                             x_attribute12                  => invoice_rec.attribute12,
                                             x_attribute13                  => invoice_rec.attribute13,
                                             x_attribute14                  => invoice_rec.attribute14,
                                             x_attribute15                  => invoice_rec.attribute15,
                                             x_creation_date                => l_date,
                                             x_created_by                   => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_date             => l_date,
                                             x_last_updated_by              => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_login            => nvl(fnd_profile.value('user_id'),1),
                                             x_true_up_amount               => invoice_rec.true_up_amt,
                                             x_true_up_status               => invoice_rec.true_up_status,
                                             x_true_up_exp_code             => invoice_rec.true_up_exp_code,
                                             x_org_id                       => invoice_rec.org_id);

            pnp_debug_pkg.debug ('l_var_rent_inv_id ...'||l_var_rent_inv_id);
            pnp_debug_pkg.debug ('For every period, call create_payment_term...'||invoice_rec.var_rent_inv_id);
	/*

            FOR payment_rec IN payment_cur(invoice_date_rec.invoice_date) LOOP
               pn_variable_term_pkg.create_reversal_terms(p_payment_term_id => payment_rec.payment_term_id
                                                         ,p_var_rent_inv_id => l_var_rent_inv_id
                                                         ,p_var_rent_type   => 'ADJUSTMENT');
            END LOOP;
	 Bug#6490896*/

         END LOOP;

      END IF;

   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.early_terminate_period (-)');

END early_terminate_period;


PROCEDURE delete_var_agreement ( p_var_rent_id IN NUMBER)
IS
BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.delete_var_agreement (+)');

   /* Delete the data from main tables */
   DELETE pn_var_vol_hist_all
   WHERE  period_id IN (SELECT period_id
                        FROM pn_var_periods_all
                        WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_bkpts_det_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_bkpts_head_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_deductions_all
   WHERE  period_id IN (SELECT period_id
                        FROM pn_var_periods_all
                        WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_rent_summ_all
   WHERE grp_date_id IN (SELECT grp_date_id
                         FROM pn_var_grp_dates_all
                         WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_constraints_all
   WHERE  period_id IN (SELECT period_id
                        FROM pn_var_periods_all
                        WHERE var_rent_id = p_var_rent_id);

   DELETE pn_var_lines_all
   WHERE period_id IN (SELECT period_id
                       FROM pn_var_periods_all
                       WHERE var_rent_id = p_var_rent_id);

   /* Delete data from defaults table */

   DELETE pn_var_bkdt_defaults_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_bkhd_defaults_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_line_defaults_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_constr_defaults_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_payment_terms_all
   WHERE  var_rent_inv_id   IN (SELECT var_rent_inv_id
                                FROM   pn_var_rent_inv_all
                                WHERE  var_rent_id = p_var_rent_id);

   DELETE pn_var_rent_inv_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_grp_dates_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_periods_all
   WHERE var_rent_id = p_var_rent_id;

   DELETE pn_var_rents_all
   WHERE var_rent_id = p_var_rent_id;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.delete_var_agreement (-)');

END delete_var_agreement;

-------------------------------------------------------------------------------
--  NAME         : process_vr_early_term
--  DESCRIPTION  : This is the main procedure, which handles the processing of
--                 VR agreement when it is contracted either directly or from
--                 lease
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_lease_id, p_var_rent_id, p_new_termn_date
--                       p_old_termn_date
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  20-MAR-07   lbala     o Bug # 5933345, Added code to delete/update from
--                          pn_var_abat_defaults_all
-------------------------------------------------------------------------------
PROCEDURE process_vr_early_term ( p_lease_id       IN NUMBER
                                 ,p_var_rent_id    IN NUMBER
                                 ,p_new_termn_date IN DATE
                                 ,p_old_termn_date IN DATE
                                 ,x_return_status  OUT NOCOPY VARCHAR2
                                 ,x_return_message  OUT NOCOPY VARCHAR2)
IS

   l_period_exists    NUMBER := NULL;
   l_errbuf           VARCHAR2(250);
   l_retcode          VARCHAR2(250);
   l_appr_term_exists VARCHAR2(1) := 'N';
   l_inv_end_dt       DATE        :=NULL;

   /* This cursor fetches all variable rent agreements, which end after the new
   termination date for a given lease or fetches information for a given agreement */

   CURSOR var_rent_cur IS
      SELECT var_rent_id, commencement_date
      FROM pn_var_rents_all
      WHERE lease_id       = NVL(p_lease_id, lease_id)
      AND var_rent_id      = NVL (p_var_rent_id, var_rent_id)
      AND (( termination_date = p_old_termn_date) OR
            (termination_date < p_old_termn_date AND termination_date > p_new_termn_date))
      AND commencement_date <= p_new_termn_date ;

   /* Fetch the period in which the new termination date lies */
   CURSOR period_id_cur(l_var_rent_id NUMBER) IS
      SELECT period_id, end_date
      FROM pn_var_periods_all
      WHERE var_rent_id = l_var_rent_id
      AND p_new_termn_date BETWEEN start_date AND end_date;

   /* Fetch the agreements which start after the new termination date */
   CURSOR variable_rent_cur IS
     SELECT var_rent_id
      FROM pn_var_rents_all
      WHERE lease_id = p_lease_id
      AND commencement_date > p_new_termn_date
      AND commencement_date < p_old_termn_date ;

   /* Check if the specified variable rent agreement has an approved term */
   CURSOR approved_term_exists_cur (p_var_rent_id NUMBER) IS
      SELECT 'Y' approve_term_exits
      FROM   pn_payment_terms_all
      WHERE  status = 'APPROVED'
      AND    var_rent_inv_id   IN (SELECT var_rent_inv_id
                                   FROM   pn_var_rent_inv_all pvi, pn_var_periods_all pvp,
                                          pn_var_rents_all pvr
                                   WHERE  pvi.period_id = pvp.period_id
                                   AND    pvr.var_rent_id = pvp.var_rent_id
                                   AND    pvr.var_rent_id = p_var_rent_id);

   /* Get the details of breakpoint header default */
   CURSOR bkhd_default_cur (p_var_rent_id NUMBER) IS
     SELECT bkhd_default_id
     FROM pn_var_bkhd_defaults_all
     WHERE var_rent_id = p_var_rent_id
     AND p_new_termn_date BETWEEN bkhd_start_date AND bkhd_end_date;

   /* Get the details of breakpoint details default */
   CURSOR bkdt_defaults_cur(p_var_rent_id NUMBER)  IS
     SELECT bkdt_default_id, bkhd_default_id
     FROM pn_var_bkdt_defaults_all
     WHERE var_rent_id = p_var_rent_id
     AND p_new_termn_date BETWEEN bkdt_start_date AND bkdt_end_date;

   /* Get the max invoice end date corresponding to the new termination date*/
  CURSOR inv_end_dt_cur(p_var_rent_id IN NUMBER) IS
   SELECT max(inv_end_date) inv_end_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    inv_end_date <= p_new_termn_date;

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.process_vr_early_term (+)');
   pnp_debug_pkg.debug ('  Parameters :');
   pnp_debug_pkg.debug ('  ------------------------------------------- :');
   pnp_debug_pkg.debug ('p_lease_id..'||p_lease_id);
   pnp_debug_pkg.debug ('p_var_rent_id ...'||p_var_rent_id);
   pnp_debug_pkg.debug ('p_new_termn_date....'||p_new_termn_date);
   pnp_debug_pkg.debug ('p_old_termn_date...'||p_old_termn_date);
   pnp_debug_pkg.debug ('  ------------------------------------------- :');

   /* Loop through the rent agreements whose termination date > new termination date */
   FOR var_rent_rec IN var_rent_cur LOOP

      pnp_debug_pkg.debug ('**************************************************************');
      pnp_debug_pkg.debug ('looping through variable rent ...'||var_rent_rec.var_rent_id);
      pnp_debug_pkg.debug ('**************************************************************');

      l_period_exists   :=  0;

      /* Delete Vol hist, Bkpt Details, bkpt headers, lines, deductions, vr summary rows,
         group dates, constraints for    agreement */
      Delete_vr_setup ( p_var_rent_id    => var_rent_rec.var_rent_id
                       ,p_new_termn_date => p_new_termn_date);

      /* Make a call to procedure remove_later_periods */
      remove_later_periods (p_var_rent_id         => var_rent_rec.var_rent_id,
                            p_new_termn_date      => p_new_termn_date,
                            p_old_termn_date      => p_old_termn_date,
                            x_return_status       => x_return_status,
                            x_return_message      => x_return_message);

      pnp_debug_pkg.debug ('after remove later periods'||p_var_rent_id||'....'||p_new_termn_date);
      /* Fetch the period in which new termination date lies */
      FOR period_id_rec IN period_id_cur(var_rent_rec.var_rent_id) LOOP

         pnp_debug_pkg.debug ('current period with new termination date ...'||period_id_rec.period_id);
         pnp_debug_pkg.debug ('end date for period with new termination date ...'||period_id_rec.end_date);

         /* Check if the new period is partial. Early terminate the setup and process the
            period if the new period is partial */
         IF period_id_rec.end_date <> p_new_termn_date THEN

            /* Make a call to procedure early_terminate setup to contract setup information
               like breakpoints, volume history, constarints etc */

            early_terminate_setup ( p_var_rent_id => var_rent_rec.var_rent_id
                                   ,p_period_id   => period_id_rec.period_id
                                   ,p_new_termn_date => p_new_termn_date);

            /* Make a call to procedure early_terminate_period */
            early_terminate_period ( p_var_rent_id      => var_rent_rec.var_rent_id,
                                     p_period_id        => period_id_rec.period_id,
                                     p_new_termn_date   => p_new_termn_date,
                                     p_old_termn_date   => p_old_termn_date,
                                     x_return_status    => x_return_status,
                                     x_return_message   => x_return_message);

         ELSE

            pnp_debug_pkg.debug(' contract the defaults only ...');

            FOR bkdt_defaults_rec IN bkdt_defaults_cur(var_rent_rec.var_rent_id) LOOP
               pn_var_bkdt_defaults_pkg.modify_row (x_bkdt_default_id => bkdt_defaults_rec.bkdt_default_id,
                                                    x_bkhd_default_id => bkdt_defaults_rec.bkhd_default_id,
                                                    x_bkdt_end_date   => p_new_termn_date);
            END LOOP;

            /* Update the Breakpoint header records in defaults */
            FOR rec IN bkhd_default_cur(var_rent_rec.var_rent_id) LOOP
               pn_var_bkhd_defaults_pkg.modify_row (x_bkhd_default_id => rec.bkhd_default_id,
                                                    x_bkhd_end_date   => p_new_termn_date);
            END LOOP;

            UPDATE pn_var_constr_defaults_all
            SET constr_end_date = p_new_termn_date
            WHERE var_rent_id = var_rent_rec.var_rent_id
            AND p_new_termn_date BETWEEN constr_start_date AND constr_end_date;

            UPDATE pn_var_line_defaults_all
            SET line_end_date = p_new_termn_date
            WHERE var_rent_id = var_rent_rec.var_rent_id
            AND p_new_termn_date BETWEEN line_start_date AND line_end_date;

            /* Get max inv end date*/
            FOR inv_dt_rec IN inv_end_dt_cur(var_rent_rec.var_rent_id) LOOP
             l_inv_end_dt := inv_dt_rec.inv_end_date;
            END LOOP;

            /* Delete all abatements whose start date is after the new max inv end date
               since start and end dates of abatements must correspond to that of
               invoice periods */
            DELETE FROM pn_var_abat_defaults_all
            WHERE var_rent_id = var_rent_rec.var_rent_id
            AND p_new_termn_date BETWEEN start_date AND end_date
            AND start_date > l_inv_end_dt;

            /*Update all abatements so that their end date is the new max inv end date*/
            UPDATE pn_var_abat_defaults_all
            SET end_date = l_inv_end_dt
            WHERE var_rent_id = var_rent_rec.var_rent_id
            AND p_new_termn_date BETWEEN start_date AND end_date;

         END IF;

      END LOOP;

      pnp_debug_pkg.debug ('after for loop');

      /* update the end date of agreement to new termination date */
      UPDATE pn_var_rents_all
      SET termination_date = p_new_termn_date
      WHERE var_rent_id    = var_rent_rec.var_rent_id;

      /* update the bkpt_update_flag to 'Y for VR agreement */
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y',
          sales_vol_update_flag = 'Y'
      WHERE var_rent_id  = var_rent_rec.var_rent_id;


   END LOOP;

   /* Loop through the rent agreements whose commencement date > new termination date */
   pnp_debug_pkg.debug ( 'lease id is ...'||p_lease_id);

   IF p_lease_id IS NOT NULL THEN
      pnp_debug_pkg.debug(' inside if ..');
      FOR variable_rent_rec IN variable_rent_cur LOOP

         l_appr_term_exists := 'N';
         pnp_debug_pkg.debug(' var rent id ...'||variable_rent_rec.var_rent_id);

         FOR rec IN approved_term_exists_cur(variable_rent_rec.var_rent_id) LOOP
            pnp_debug_pkg.debug (' approved term exists ...');
            l_appr_term_exists := rec.approve_term_exits;
         END LOOP;

         pnp_debug_pkg.debug ('l_appr_term_exists ...'||l_appr_term_exists);

         IF l_appr_term_exists = 'N' THEN
            delete_var_agreement(p_var_rent_id => variable_rent_rec.var_rent_id);
         END IF;

      END LOOP;
   END IF;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.process_vr_early_term (-)');

EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.debug ('Process_vr_early_term Error:'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_message := sqlerrm;
END;

-------------------------------------------------------------------------------
--  NAME         : extend_defaults
--  DESCRIPTION  : This procedure handles the extension of existing break
--                 point set up
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_var_rent_id, p_new_termn_date, p_old_termn_date
--                 OUT:  p_return_status, p_return_message
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
-------------------------------------------------------------------------------
PROCEDURE extend_defaults ( p_var_rent_id     IN NUMBER
                           ,p_old_termn_date  IN DATE
                           ,p_new_termn_date  IN DATE)
IS

   CURSOR exists_line_cur IS
   SELECT line_default_id
   FROM   pn_var_line_defaults_all
   WHERE  var_rent_id = p_var_rent_id;

   CURSOR exists_hd_def_cur (p_linedefid NUMBER) IS
   SELECT bkhd_default_id
   FROM   pn_var_bkhd_defaults_all
   WHERE  line_default_id = p_linedefid;

   CURSOR bkpt_data_exists IS
      SELECT 'x' bkpt_exists
      FROM DUAL
      WHERE EXISTS (SELECT bkhd_default_id
                    FROM pn_var_bkpts_head_all
                    WHERE var_rent_id = p_var_rent_id
                    AND bkhd_default_id IS NOT NULL);

   CURSOR constr_data_exists IS
      SELECT 'x'
      FROM DUAL
      WHERE EXISTS (SELECT constraint_id
                    FROM pn_var_constraints_all
                    WHERE period_id IN (SELECT PERIOD_ID
                                        FROM pn_var_periods_all
                                        WHERE var_rent_id = p_var_rent_id)
                    AND constr_default_id IS NOT NULL);

    /* Get the details of breakpoint header default */
   CURSOR bkhd_default_cur IS
     SELECT bkhd_default_id
     FROM pn_var_bkhd_defaults_all
     WHERE var_rent_id  = p_var_rent_id
     AND bkhd_end_date  = p_old_termn_date;

   /* Get the details of breakpoint details default */
   CURSOR bkdt_defaults_cur IS
     SELECT bkdt_default_id, bkhd_default_id
     FROM pn_var_bkdt_defaults_all
     WHERE var_rent_id  = p_var_rent_id
     AND bkdt_end_date = p_old_termn_date
     AND bkhd_default_id IN ( SELECT bkhd_default_id
                              FROM  pn_var_bkhd_defaults_all
                              WHERE var_rent_id  = p_var_rent_id
                              AND bkhd_end_date  = p_new_termn_date
                              AND break_type = 'ARTIFICIAL');


   l_linedefid     NUMBER;
   l_errbuf        VARCHAR2(250);
   l_ret_code      VARCHAR2(250);
   l_bkpt_exists   VARCHAR2(1);

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.extend_defaults (+)');
   pnp_debug_pkg.debug ('p_var_rent_id .. '||p_var_rent_id);
   pnp_debug_pkg.debug ('p_old_termn_date ..'||p_old_termn_date);
   pnp_debug_pkg.debug ('p_new_termn_date ..'||p_new_termn_date);

   UPDATE pn_var_line_defaults_all
   SET line_end_date  = p_new_termn_date
   WHERE var_rent_id  = p_var_rent_id
   AND line_end_date  = p_old_termn_date;

   /* Update the Breakpoint header records in defaults */
   FOR rec IN bkhd_default_cur LOOP
      pn_var_bkhd_defaults_pkg.modify_row (x_bkhd_default_id => rec.bkhd_default_id,
                                           x_bkhd_end_date   => p_new_termn_date);
   END LOOP;

   /* Update the Breakpoint detail records in defaults */
   FOR bkdt_defaults_rec IN bkdt_defaults_cur LOOP
      pn_var_bkdt_defaults_pkg.modify_row (x_bkdt_default_id => bkdt_defaults_rec.bkdt_default_id,
                                           x_bkhd_default_id => bkdt_defaults_rec.bkhd_default_id,
                                           x_bkdt_end_date   => p_new_termn_date);
   END LOOP;

   UPDATE pn_var_constr_defaults_all
   SET constr_end_date  = p_new_termn_date
   WHERE var_rent_id  = p_var_rent_id
   AND constr_end_date  = p_old_termn_date;

   /* This generates line items, breakpoint header and details in main tables */
   pnp_debug_pkg.debug ('calling procedure pn_var_defaults_pkg.create_default_lines ..');
   FOR rec IN bkpt_data_exists LOOP
      l_bkpt_exists := rec.bkpt_exists;
   END LOOP;

   /* This generates the breakpoint details for Natural breakpoints */
   pn_var_natural_bp_pkg.build_bkpt_details_main(errbuf        => l_errbuf,
                                                 retcode       => l_ret_code,
                                                 p_var_rent_id => p_var_rent_id);


   IF l_bkpt_exists IS NOT NULL THEN

      DELETE FROM pn_var_bkpts_det_all
      WHERE var_rent_id = p_var_rent_id;

      DELETE FROM pn_var_bkpts_head_all
      WHERE var_rent_id = p_var_rent_id;

      pn_var_defaults_pkg.create_setup_data (x_var_rent_id => p_var_rent_id);
   END IF;

   /* This generates constraint records in main tables */
   pnp_debug_pkg.debug ('calling procedure pn_var_defaults_pkg.create_default_constraints ..');
   FOR rec IN constr_data_exists LOOP
      DELETE FROM pn_var_constraints_all
      WHERE  period_id IN (SELECT period_id
                           FROM   pn_var_periods_all
                           WHERE  var_rent_id = p_var_rent_id);

      pn_var_defaults_pkg.create_default_constraints (x_var_rent_id => p_var_rent_id);
   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.extend_defaults (-)');
END;

-------------------------------------------------------------------------------
--  NAME         : Create_setup_exp
--  DESCRIPTION  : This procedure handles the extension of existing break point
--                 setup
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_var_rent_id, p_period_id
--                 OUT:  p_return_status, p_return_message
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
-------------------------------------------------------------------------------
PROCEDURE create_setup_exp ( p_var_rent_id IN NUMBER
                            ,p_period_id   IN NUMBER)
IS

   /* This cursor fetches period, which start after the last period */
   CURSOR period_cur IS
      SELECT period_id, start_date, end_date
      FROM pn_var_periods_all
      WHERE var_rent_id = p_var_rent_id
      AND start_date > ( SELECT end_date
                         FROM pn_var_periods_all
                         WHERE period_id = p_period_id);

   /* This cursor fetches information abouth the period which was the last one
      before contraction */
   CURSOR last_period_cur IS
      SELECT end_date
      FROM pn_var_periods_all
      WHERE period_id = p_period_id;

   /* This cursor fetches the line record data for last period before expansion */
   CURSOR line_cur IS
      SELECT sales_type_code
            ,item_category_code
            ,comments
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,org_id
            ,line_template_id
            ,agreement_template_id
            ,line_default_id
            ,var_rent_id
            ,line_item_id
      FROM pn_var_lines_all
      WHERE period_id = p_period_id;

   /* This cursor fetches the breakpoint header record data,
      which ends on end date of last period before expansion */
   CURSOR bkpt_head_cur( p_line_item_id IN NUMBER
                        ,p_end_date IN DATE)
   IS
      SELECT bkpt_header_id,
             line_item_id,
             break_type,
             base_rent_type,
             natural_break_rate,
             base_rent,
             breakpoint_type,
             bkhd_default_id,
             var_rent_id,
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
             attribute15,
             org_id
      FROM pn_var_bkpts_head_all
      WHERE line_item_id = p_line_item_id
      AND bkhd_end_date = p_end_date;

   /* This cursor fetches the breakpoint detail record data,
      which ends on end date of last period before expansion */
   CURSOR bkpt_detail_cur( p_bkpt_header_id IN NUMBER
                          ,p_end_date IN DATE)
   IS
      SELECT period_bkpt_vol_start,
             period_bkpt_vol_end,
             group_bkpt_vol_start,
             group_bkpt_vol_end,
             bkpt_rate,
             comments,
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
             attribute15,
             org_id,
             annual_basis_amount,
             bkdt_default_id
      FROM pn_var_bkpts_det_all
      WHERE bkpt_header_id = p_bkpt_header_id
      AND bkpt_end_date = p_end_date;


   /* This cursor fetches the constraint records for last period before expansion */
   CURSOR constraint_cur (p_end_date DATE) IS
      SELECT constr_cat_code
            ,type_code
            ,amount
            ,comments
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,org_id
            ,agreement_template_id
            ,constr_template_id
            ,constr_default_id
      FROM pn_var_constraints_all
      WHERE period_id = p_period_id
      AND constr_end_date = p_end_date;


   l_rowId                  VARCHAR2(18)  := NULL;
   l_line_item_id           NUMBER        := NULL;
   l_line_item_num          NUMBER        := NULL;
   l_end_date               DATE          := NULL;
   l_bkpt_header_id         NUMBER        := NULL;
   l_bkpt_detail_id         NUMBER        := NULL;
   l_bkpt_detail_num        NUMBER        := NULL;
   l_constrid               NUMBER        := NULL;
   l_constrnum              NUMBER        := NULL;

BEGIN

   pnp_debug_pkg.debug ('pn_var_rent_pkg.create_setup_exp (+)');
   pnp_debug_pkg.debug ('p_var_rent_id .. '||p_var_rent_id);
   pnp_debug_pkg.debug ('p_period_id ..'||p_period_id);

   /* Fetch the end date of period which was the last one before expansion */
   FOR last_period_rec IN  last_period_cur LOOP
      l_end_date := last_period_rec.end_date;
   END LOOP;

   /* Loop through line records of period which was the last one before expansion */
   FOR line_rec IN line_cur LOOP

      pnp_debug_pkg.debug ('refernce line record is  ..'||line_rec.line_item_id);

      /* Loop through the periods which have been created due to VR expansion to
         create setup data for them */
      FOR period_rec IN period_cur LOOP

         pnp_debug_pkg.debug ('period for which data is being inserted is  ..'||period_rec.period_id);
         l_rowid := NULL;
         l_line_item_id := NULL;
         l_line_item_num := NULL;

         /* generate line item for this period using the data from last period */
         pn_var_lines_pkg.insert_row(x_rowid                 => l_rowid,
                                     x_line_item_id          => l_line_item_id,
                                     x_line_item_num         => l_line_item_num,
                                     x_period_id             => period_rec.period_id,
                                     x_sales_type_code       => line_rec.sales_type_code,
                                     x_item_category_code    => line_rec.item_category_code,
                                     x_comments              => line_rec.comments,
                                     x_attribute_category    => line_rec.attribute_category ,
                                     x_attribute1            => line_rec.attribute1,
                                     x_attribute2            => line_rec.attribute2,
                                     x_attribute3            => line_rec.attribute3,
                                     x_attribute4            => line_rec.attribute4,
                                     x_attribute5            => line_rec.attribute5,
                                     x_attribute6            => line_rec.attribute6,
                                     x_attribute7            => line_rec.attribute7,
                                     x_attribute8            => line_rec.attribute8,
                                     x_attribute9            => line_rec.attribute9,
                                     x_attribute10           => line_rec.attribute10,
                                     x_attribute11           => line_rec.attribute11,
                                     x_attribute12           => line_rec.attribute12,
                                     x_attribute13           => line_rec.attribute13,
                                     x_attribute14           => line_rec.attribute14,
                                     x_attribute15           => line_rec.attribute15,
                                     x_org_id                => line_rec.org_id,
                                     x_creation_date         => sysdate,
                                     x_created_by            => NVL(fnd_profile.value('USER_ID'),0),
                                     x_last_update_date      => sysdate,
                                     x_last_updated_by       => NVL(fnd_profile.value('USER_ID'),0),
                                     x_last_update_login     => NVL(fnd_profile.value('USER_ID'),0),
                                     x_line_template_id      => line_rec.line_template_id,
                                     x_agreement_template_id => line_rec.agreement_template_id,
                                     x_line_default_id       => line_rec.line_default_id,
                                     x_var_rent_id           => p_var_rent_id);

         pnp_debug_pkg.debug ('line item inserted is l_line_item_id ..'||l_line_item_id);
         /* Generate the breakpoint header associated with this line item */
         FOR bkpt_head_rec IN bkpt_head_cur (line_rec.line_item_id, l_end_date) LOOP
           l_rowid              := NULL;
           l_bkpt_header_id     := NULL;
           pn_var_bkpts_head_pkg.insert_row(x_rowid                     => l_rowid,
                                            x_bkpt_header_id            => l_bkpt_header_id,
                                            x_line_item_id              => l_line_item_id,
                                            x_period_id                 => period_rec.period_id,
                                            x_break_type                => bkpt_head_rec.break_type,
                                            x_base_rent_type            => bkpt_head_rec.base_rent_type,
                                            x_natural_break_rate        => bkpt_head_rec.natural_break_rate,
                                            x_base_rent                 => bkpt_head_rec.base_rent,
                                            x_breakpoint_type           => bkpt_head_rec.breakpoint_type,
                                            x_bkhd_default_id           => bkpt_head_rec.bkhd_default_id,
                                            x_bkhd_start_date           => period_rec.start_date,
                                            x_bkhd_end_date             => period_rec.end_date,
                                            x_var_rent_id               => p_var_rent_id,
                                            x_attribute_category        => bkpt_head_rec.attribute_category,
                                            x_attribute1                => bkpt_head_rec.attribute1,
                                            x_attribute2                => bkpt_head_rec.attribute2,
                                            x_attribute3                => bkpt_head_rec.attribute3,
                                            x_attribute4                => bkpt_head_rec.attribute4,
                                            x_attribute5                => bkpt_head_rec.attribute5,
                                            x_attribute6                => bkpt_head_rec.attribute6,
                                            x_attribute7                => bkpt_head_rec.attribute7,
                                            x_attribute8                => bkpt_head_rec.attribute8,
                                            x_attribute9                => bkpt_head_rec.attribute9,
                                            x_attribute10               => bkpt_head_rec.attribute10,
                                            x_attribute11               => bkpt_head_rec.attribute11,
                                            x_attribute12               => bkpt_head_rec.attribute12,
                                            x_attribute13               => bkpt_head_rec.attribute13,
                                            x_attribute14               => bkpt_head_rec.attribute14,
                                            x_attribute15               => bkpt_head_rec.attribute15,
                                            x_org_id                    => bkpt_head_rec.org_id,
                                            x_creation_date             => sysdate,
                                            x_created_by                => NVL(fnd_profile.value('USER_ID'),0),
                                            x_last_update_date          => sysdate,
                                            x_last_updated_by           => NVL(fnd_profile.value('USER_ID'),0),
                                            x_last_update_login         => NVL(fnd_profile.value('LOGIN_ID'),0));

            pnp_debug_pkg.debug ('breakpoint header inserted is l_bkpt_header_id ..'||l_bkpt_header_id);

            /* Generate the breakpoint details associated with this breakpoint header */
            FOR bkpt_detail_rec IN bkpt_detail_cur( bkpt_head_rec.bkpt_header_id, l_end_date) LOOP
               l_rowid              := NULL;
               l_bkpt_detail_id     := NULL;
               l_bkpt_detail_num    := NULL;

               pn_var_bkpts_det_pkg.insert_row(x_rowid                 => l_rowid,
                                               x_bkpt_detail_id        => l_bkpt_detail_id,
                                               x_bkpt_detail_num       => l_bkpt_detail_num,
                                               x_bkpt_header_id        => l_bkpt_header_id,
                                               x_bkpt_start_date       => period_rec.start_date,
                                               x_bkpt_end_date         => period_rec.end_date,
                                               x_period_bkpt_vol_start => bkpt_detail_rec.period_bkpt_vol_start,
                                               x_period_bkpt_vol_end   => bkpt_detail_rec.period_bkpt_vol_end,
                                               x_group_bkpt_vol_start  => bkpt_detail_rec.group_bkpt_vol_start,
                                               x_group_bkpt_vol_end    => bkpt_detail_rec.group_bkpt_vol_end,
                                               x_bkpt_rate             => bkpt_detail_rec.bkpt_rate,
                                               x_bkdt_default_id       => bkpt_detail_rec.bkdt_default_id,
                                               x_var_rent_id           => p_var_rent_id,
                                               x_comments              => bkpt_detail_rec.comments,
                                               x_attribute_category    => bkpt_detail_rec.attribute_category,
                                               x_attribute1            => bkpt_detail_rec.attribute1,
                                               x_attribute2            => bkpt_detail_rec.attribute2,
                                               x_attribute3            => bkpt_detail_rec.attribute3,
                                               x_attribute4            => bkpt_detail_rec.attribute4,
                                               x_attribute5            => bkpt_detail_rec.attribute5,
                                               x_attribute6            => bkpt_detail_rec.attribute6,
                                               x_attribute7            => bkpt_detail_rec.attribute7,
                                               x_attribute8            => bkpt_detail_rec.attribute8,
                                               x_attribute9            => bkpt_detail_rec.attribute9,
                                               x_attribute10           => bkpt_detail_rec.attribute10,
                                               x_attribute11           => bkpt_detail_rec.attribute11,
                                               x_attribute12           => bkpt_detail_rec.attribute12,
                                               x_attribute13           => bkpt_detail_rec.attribute13,
                                               x_attribute14           => bkpt_detail_rec.attribute14,
                                               x_attribute15           => bkpt_detail_rec.attribute15,
                                               x_org_id                => bkpt_detail_rec.org_id,
                                               x_creation_date         => sysdate,
                                               x_created_by            => nvl(fnd_profile.value('user_id'),0),
                                               x_last_update_date      => sysdate,
                                               x_last_updated_by       => nvl(fnd_profile.value('user_id'),0),
                                               x_last_update_login     => nvl(fnd_profile.value('user_id'),0),
                                               x_annual_basis_amount   => bkpt_detail_rec.annual_basis_amount
                                              );

               pnp_debug_pkg.debug ('breakpoint detail inserted is l_bkpt_detail_id ..'||l_bkpt_detail_id);

            END LOOP; /* end loop for bkpt detail */

         END LOOP; /* end loop for bkpt header */

      END LOOP; /* end loop for period_rec */

   END LOOP; /* end loop for line item */

   /* Loop through constraint records of period which was the last one before expansion */
   FOR constraint_rec IN constraint_cur(l_end_date) LOOP

      /* Loop through the periods which have been created due to VR expansion to
         create constraint data for them */
      FOR period_rec IN period_cur LOOP
         l_rowid              := NULL;
         l_constrid           := NULL;
         l_constrnum          := NULL;

         pn_var_constraints_pkg.insert_row(  x_rowid                 => l_rowid,
                                             x_constraint_id         => l_constrid,
                                             x_constraint_num        => l_constrnum,
                                             x_period_id             => period_rec.period_id,
                                             x_constr_cat_code       => constraint_rec.constr_cat_code,
                                             x_type_code             => constraint_rec.type_code,
                                             x_amount                => constraint_rec.amount,
                                             x_agreement_template_id => constraint_rec.agreement_template_id,
                                             x_constr_template_id    => constraint_rec.constr_template_id,
                                             x_constr_default_id     => constraint_rec.constr_default_id,
                                             x_comments              => constraint_rec.comments,
                                             x_attribute_category    => constraint_rec.attribute_category,
                                             x_attribute1            => constraint_rec.attribute1,
                                             x_attribute2            => constraint_rec.attribute2,
                                             x_attribute3            => constraint_rec.attribute3,
                                             x_attribute4            => constraint_rec.attribute4,
                                             x_attribute5            => constraint_rec.attribute5,
                                             x_attribute6            => constraint_rec.attribute6,
                                             x_attribute7            => constraint_rec.attribute7,
                                             x_attribute8            => constraint_rec.attribute8,
                                             x_attribute9            => constraint_rec.attribute9,
                                             x_attribute10           => constraint_rec.attribute10,
                                             x_attribute11           => constraint_rec.attribute11,
                                             x_attribute12           => constraint_rec.attribute12,
                                             x_attribute13           => constraint_rec.attribute13,
                                             x_attribute14           => constraint_rec.attribute14,
                                             x_attribute15           => constraint_rec.attribute15,
                                             x_org_id                => constraint_rec.org_id,
                                             x_creation_date         => sysdate,
                                             x_created_by            => nvl(fnd_profile.value('user_id'),0),
                                             x_last_update_date      => sysdate,
                                             x_last_updated_by       => nvl(fnd_profile.value('user_id'),0),
                                             x_last_update_login     => nvl(fnd_profile.value('user_id'),0),
                                             x_constr_start_date     => period_rec.start_date,
                                             x_constr_end_date       => period_rec.end_date);
      END LOOP;

   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.create_setup_exp (-)');
END;

-------------------------------------------------------------------------------
--  NAME         : update_setup_exp
--  DESCRIPTION  : This procedure handles the extension of existing break point
--                set up
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_var_rent_id, p_old_termn_date, p_period_id
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
-------------------------------------------------------------------------------
PROCEDURE update_setup_exp ( p_var_rent_id     IN NUMBER
                            ,p_old_termn_date  IN DATE
                            ,p_period_id       IN NUMBER)
IS
   CURSOR period_cur IS
      SELECT end_date
      FROM pn_var_periods_all
      WHERE var_rent_id = p_var_rent_id
      AND period_id = p_period_id;

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.update_setup_exp (+)');
   pnp_debug_pkg.debug ('p_var_rent_id .. '||p_var_rent_id);
   pnp_debug_pkg.debug ('p_old_termn_date ..'||p_old_termn_date);

   FOR period_rec IN period_cur LOOP

      pnp_debug_pkg.debug ('last_period_rec.period_id ...'||p_period_id);
      pnp_debug_pkg.debug ('last_period_rec.end_date ....'||period_rec.end_date);

      UPDATE pn_var_bkpts_head_all
      SET bkhd_end_date  = period_rec.end_date
      WHERE var_rent_id  = p_var_rent_id
      AND bkhd_end_date  = p_old_termn_date;

      UPDATE pn_var_bkpts_det_all
      SET bkpt_end_date  = period_rec.end_date
      WHERE var_rent_id  = p_var_rent_id
      AND bkpt_end_date  = p_old_termn_date;

      UPDATE pn_var_constraints_all
      SET constr_end_date  = period_rec.end_date
      WHERE period_id  = p_period_id
      AND constr_end_date  = p_old_termn_date;

      create_setup_exp (  p_var_rent_id => p_var_rent_id
                        , p_period_id   => p_period_id);

   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.update_setup_exp (-)');

END;

-------------------------------------------------------------------------------
--  NAME         : create_rev_term_LY_FLY
--  DESCRIPTION  : This procedure will be calle when reversal terms need to be
--                 created for variable rent agreements with proration rule
--                 as 'LY or 'FLY'
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_var_rent_id, p_last_period_id
--                 OUT:  NIL
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  21-SEP-06   piagrawa  o Created
--  03-DEC-07   acprakas  o Bug#6490896. Modified to avoid auto creation of payment/billing terms
-------------------------------------------------------------------------------
PROCEDURE create_rev_term_LY_FLY ( p_last_period_id  IN NUMBER
                                  ,p_var_rent_id     IN NUMBER)
IS

   /* This cursor fetches the invoices for LY/FLY calculation */
   CURSOR invoice_date_cur (p_period_id NUMBER) IS
      SELECT  DISTINCT invoice_date
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND    NVL(actual_exp_code, 'N') = 'Y'
      AND    NVL(actual_invoiced_amount, 0) <> 0;

   /* This cursor fetches the invoices for LY/FLY calculation */
   CURSOR invoice_cur ( p_period_id    NUMBER
                           ,p_invoice_date DATE
            ,p_adjust_num   NUMBER) IS
      SELECT  *
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND   (NVL(actual_exp_code, 'N') = 'Y' OR
             NVL(variance_exp_code, 'N') = 'Y')
      AND    NVL(actual_invoiced_amount, 0) <> 0
      AND    invoice_date = p_invoice_date
      AND    adjust_num = p_adjust_num;

   /* Fetches the amount for the particular invoice date */
   CURSOR actual_invoice_amount (p_period_id NUMBER,
                                 p_invoice_date DATE) IS
      SELECT SUM(actual_invoiced_amount) actual_amount
      FROM   pn_var_rent_inv_all
      WHERE var_rent_inv_id IN ( SELECT var_rent_inv_id
                                 FROM   pn_var_rent_inv_all
                                 WHERE  period_id = p_period_id
                                 AND    (NVL(actual_exp_code, 'N') = 'Y' OR
                                         NVL(variance_exp_code, 'N') = 'Y')
                                 AND    NVL(actual_invoiced_amount, 0) <> 0
                                 AND    invoice_date = p_invoice_date);

      /* Fetches payment term information for a invoice id */
   CURSOR payment_cur(p_period_id NUMBER) IS
      SELECT payment_term_id
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id IN ( SELECT var_rent_inv_id
                                 FROM   pn_var_rent_inv_all
                                 WHERE  period_id = p_period_id
                                 AND    NVL(actual_exp_code, 'N') = 'Y'
                                 AND    NVL(actual_invoiced_amount, 0) <> 0);

   /* Fetches the maximum adjust num cursor */
   CURSOR max_adjust_num_cur (p_period_id NUMBER,
                              p_invoice_date DATE) IS
      SELECT max(adjust_num) max_adjust_num
      FROM   pn_var_rent_inv_all
      WHERE  period_id = p_period_id
      AND    invoice_date = p_invoice_date;

   l_rowid               ROWID;
   l_var_rent_inv_id     NUMBER;
   l_max_adjust_num      NUMBER := 0;
   l_actual_invoiced_amount NUMBER := 0;
   l_invoice_inserted    BOOLEAN := FALSE;
BEGIN

   pnp_debug_pkg.debug ('pn_var_rent_pkg.create_rev_term_LY_FLY (+) ');

   DELETE pn_payment_terms_all
   WHERE  var_rent_inv_id IN (SELECT var_rent_inv_id
                              FROM   pn_var_rent_inv_all
                              WHERE  period_id = p_last_period_id
                              AND    NVL(actual_exp_code, 'N') <> 'Y')
   AND   status <> 'APPROVED';

   DELETE pn_var_rent_inv_all
   WHERE  period_id = p_last_period_id
   AND    NVL(actual_exp_code, 'N') <> 'Y';

   pnp_debug_pkg.debug ('Loop for invoices for true up and for last year calculation. ');
   /* Loop for invoices for true up and for last year calculation.*/
   FOR invoice_date_rec IN invoice_date_cur(p_last_period_id) LOOP

      /* Fetch the maximum adjust number for a particular invoice date */
      FOR max_adjust_num_rec IN max_adjust_num_cur(p_last_period_id, invoice_date_rec.invoice_date)
      LOOP
         l_max_adjust_num := max_adjust_num_rec.max_adjust_num;
      END LOOP;

      /* Fetch the total amount that needs to be invoiced */
      FOR rec IN actual_invoice_amount(p_last_period_id, invoice_date_rec.invoice_date)  LOOP
         l_actual_invoiced_amount := rec.actual_amount;
      END LOOP;

      /* If the amount for reversal term is 0 , do not insert an invoice */
      IF l_actual_invoiced_amount <> 0 THEN

         /* Loop for the invoice with amx adjust num for a aprticular invoice date */
         FOR invoice_rec IN invoice_cur(p_last_period_id, invoice_date_rec.invoice_date, l_max_adjust_num ) LOOP

            /* Set var rent inv id to null before inserting a row */
            l_var_rent_inv_id := NULL;
            l_rowid           := NULL;

            pn_var_rent_inv_pkg.insert_row ( x_rowid                        => l_rowid,
                                             x_var_rent_inv_id              => l_var_rent_inv_id,
                                             x_adjust_num                   => l_max_adjust_num  + 1,
                                             x_invoice_date                 => invoice_rec.invoice_date,
                                             x_for_per_rent                 => invoice_rec.for_per_rent,
                                             x_tot_act_vol                  => 0,
                                             x_act_per_rent                 => 0,
                                             x_constr_actual_rent           => 0,
                                             x_abatement_appl               => invoice_rec.abatement_appl,
                                             x_rec_abatement                => invoice_rec.rec_abatement,
                                             x_rec_abatement_override       => invoice_rec.rec_abatement_override,
                                             x_negative_rent                => invoice_rec.negative_rent ,
                                             x_actual_invoiced_amount       => -l_actual_invoiced_amount,
                                             x_period_id                    => invoice_rec.period_id,
                                             x_var_rent_id                  => p_var_rent_id,
                                             x_forecasted_term_status       => invoice_rec.forecasted_term_status,
                                             x_variance_term_status         => invoice_rec.variance_term_status,
                                             x_actual_term_status           => 'N', --invoice_rec.actual_term_status, Bug#6490896
                                             x_forecasted_exp_code          => 'N',
                                             x_variance_exp_code            => 'N',
                                             x_actual_exp_code              => 'N',
                                             x_credit_flag                  => 'Y',
                                             x_comments                     => 'negative invoices',
                                             x_attribute_category           => invoice_rec.attribute_category,
                                             x_attribute1                   => invoice_rec.attribute1,
                                             x_attribute2                   => invoice_rec.attribute2,
                                             x_attribute3                   => invoice_rec.attribute3,
                                             x_attribute4                   => invoice_rec.attribute4,
                                             x_attribute5                   => invoice_rec.attribute5,
                                             x_attribute6                   => invoice_rec.attribute6,
                                             x_attribute7                   => invoice_rec.attribute7,
                                             x_attribute8                   => invoice_rec.attribute8,
                                             x_attribute9                   => invoice_rec.attribute9,
                                             x_attribute10                  => invoice_rec.attribute10,
                                             x_attribute11                  => invoice_rec.attribute11,
                                             x_attribute12                  => invoice_rec.attribute12,
                                             x_attribute13                  => invoice_rec.attribute13,
                                             x_attribute14                  => invoice_rec.attribute14,
                                             x_attribute15                  => invoice_rec.attribute15,
                                             x_creation_date                => SYSDATE,
                                             x_created_by                   => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_date             => SYSDATE,
                                             x_last_updated_by              => nvl(fnd_profile.value('user_id'),1),
                                             x_last_update_login            => nvl(fnd_profile.value('user_id'),1),
                                             x_true_up_amount               => invoice_rec.true_up_amt,
                                             x_true_up_status               => invoice_rec.true_up_status,
                                             x_true_up_exp_code             => invoice_rec.true_up_exp_code,
                                             x_org_id                       => invoice_rec.org_id);

            pnp_debug_pkg.debug ('l_var_rent_inv_id ...'||l_var_rent_inv_id);
            pnp_debug_pkg.debug ('For every period, call create_payment_term...'||invoice_rec.var_rent_inv_id);
	    /*
            FOR payment_rec IN payment_cur(invoice_rec.var_rent_inv_id) LOOP
               pn_variable_term_pkg.create_reversal_terms(p_payment_term_id => payment_rec.payment_term_id
                                                         ,p_var_rent_inv_id => l_var_rent_inv_id
                                                         ,p_var_rent_type   => 'ADJUSTMENT');
            END LOOP;
	   Bug#6490896*/

         END LOOP;
      END IF;
   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.create_rev_term_LY_FLY (-) ');

END create_rev_term_LY_FLY;

-------------------------------------------------------------------------------
--  NAME         : process_vr_ext
--  DESCRIPTION  : This procedure will be calles when the termination date
--                 of the VR agreement is extended or if the start date is
--                 changed to an earlier start date due to either change in the
--                 lease agreement or the VR agreement
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_lease_id, p_var_rent_id, p_new_termn_date
--                       p_old_termn_date, p_extend_setup
--                 OUT:  p_return_status, p_return_message
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
-------------------------------------------------------------------------------
PROCEDURE process_vr_ext (p_lease_id       IN NUMBER
                         ,p_var_rent_id    IN NUMBER
                         ,p_new_termn_date IN DATE
                         ,p_old_termn_date IN DATE
                         ,p_extend_setup    IN VARCHAR2
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_return_message OUT NOCOPY VARCHAR2)
IS

   /* Fetches the period in which the old termination date falls */
   CURSOR last_period_cur (p_var_rent_id NUMBER) IS
      SELECT period_id, partial_period
      FROM pn_var_periods_all
      WHERE var_rent_id = p_var_rent_id
      AND p_old_termn_date BETWEEN start_date AND end_date;

   /* This retrieves the variable rent agreements which need to be extended */
   CURSOR main_vr_cur IS
      SELECT  pvr.var_rent_id
            , pvr.cumulative_vol
            , pvr.proration_rule
            , pvd.use_gl_calendar
            , pvd.year_start_date
            , pvr.commencement_date
      FROM   pn_var_rents_all pvr, pn_var_rent_dates_all pvd
      WHERE  pvr.lease_id = NVL (p_lease_id, pvr.lease_id)
      AND    pvr.var_rent_id = NVL (p_var_rent_id, pvr.var_rent_id)
      AND    pvr.termination_date = p_old_termn_date
      AND    pvd.var_rent_id = pvr.var_rent_id;


   /* This returns Y if record exits in line or constraint defaults */
   CURSOR default_exists (p_var_rent_id NUMBER) IS
      SELECT 'Y'
      FROM DUAL
      WHERE EXISTS (SELECT var_rent_id
                    FROM pn_var_line_defaults_all
                    WHERE var_rent_id = p_var_rent_id)
      OR EXISTS (SELECT var_rent_id
                 FROM pn_var_constr_defaults_all
                 WHERE var_rent_id = p_var_rent_id);

   l_default_exists     VARCHAR2 (1) := 'N';
   l_partial_flag       VARCHAR2 (1);
   l_last_period_id     NUMBER;
   l_errbuf             VARCHAR2(250) := NULL;
   l_retcode            VARCHAR2(250);
   l_date               DATE := SYSDATE;

BEGIN
   pnp_debug_pkg.debug ('pn_var_rent_pkg.process_vr_ext (+)');
   pnp_debug_pkg.debug ('p_lease_id      '||p_lease_id      );
   pnp_debug_pkg.debug ('p_var_rent_id   '||p_var_rent_id   );
   pnp_debug_pkg.debug ('p_new_termn_date'||p_new_termn_date);
   pnp_debug_pkg.debug ('p_old_termn_date'||p_old_termn_date);
   pnp_debug_pkg.debug ('p_extend_setup   '||p_extend_setup   );

   FOR main_vr_rec IN main_vr_cur LOOP

      pnp_debug_pkg.debug ('**************************************************************');
      pnp_debug_pkg.debug ('Processing variable rent agreement ...'||main_vr_rec.var_rent_id);
      pnp_debug_pkg.debug ('**************************************************************');

      /* Fetch the last period id and partial flag before expansion */
      FOR last_period_rec IN last_period_cur(main_vr_rec.var_rent_id) LOOP
         l_partial_flag  := last_period_rec.partial_period;
         l_last_period_id  := last_period_rec.period_id;
         pnp_debug_pkg.debug ('l_last_period_id ...'||l_last_period_id);
         pnp_debug_pkg.debug ('l_partial_flag ...'||l_partial_flag);
      END LOOP;

      /* Update the vr agreement with the new termination date */
      pnp_debug_pkg.debug ('Update the vr agreement with the new termination date ...');

      UPDATE pn_var_rents_all
      SET termination_date = p_new_termn_date
      WHERE var_rent_id    = main_vr_rec.var_rent_id;

      /* call appropriate procedures to create new periods or activate the inactive one
         beyond the old termination date */
      IF  NVL(main_vr_rec.use_gl_calendar,'N') = 'N' THEN

         pnp_debug_pkg.debug ('making a call to create_var_rent_periods_nocal ...');
         pn_var_rent_pkg.create_var_rent_periods_nocal(p_var_rent_id    => main_vr_rec.var_rent_id ,
                                                       p_cumulative_vol => main_vr_rec.cumulative_vol ,
                                                       p_yr_start_date  => main_vr_rec.year_start_date);

      ELSIF  NVL(main_vr_rec.use_gl_calendar,'N') = 'Y' THEN
         pnp_debug_pkg.debug ('making a call to create_var_rent_periods ...');
         pn_var_rent_pkg.create_var_rent_periods( p_var_rent_id    => main_vr_rec.var_rent_id,
                                                  p_cumulative_vol => main_vr_rec.cumulative_vol,
                                                  p_comm_date      => main_vr_rec.commencement_date,
                                                  p_term_date      => p_new_termn_date,
                                                  p_create_flag    => 'Y');
      END IF;

      /* Check if breakpoints need to be extended along with the agreement */
      IF p_extend_setup = 'Y' THEN

         /* Check if data exists in defaults tables for this variable rent */
         FOR rec IN default_exists(main_vr_rec.var_rent_id) LOOP
            l_default_exists := 'Y';
            pnp_debug_pkg.debug ('l_default_exists is Y');
         END LOOP;

         pnp_debug_pkg.debug ('calling appropriate proc after checking if defaults exist ...');
         IF l_default_exists = 'Y' THEN
            pnp_debug_pkg.debug ('calling proc extend_defaults .. if defaults exist ...');
            extend_defaults (  p_var_rent_id    => main_vr_rec.var_rent_id
                             , p_old_termn_date => p_old_termn_date
                             , p_new_termn_date => p_new_termn_date );
         ELSE
            pnp_debug_pkg.debug ('calling proc update_setup_exp .. if defaults do not exist ...');
            update_setup_exp (  p_var_rent_id    => main_vr_rec.var_rent_id
                              , p_old_termn_date => p_old_termn_date
                              , p_period_id      => l_last_period_id);
         END IF;

      ELSE
         /* Undo the breakpoint setup */
         pn_var_defaults_pkg.delete_default_lines (main_vr_rec.var_rent_id);
      END IF;

      IF l_partial_flag = 'Y' THEN

         /* Create reversal terms for Last year and first-last year */
         IF main_vr_rec.proration_rule IN ('LY', 'FLY')
         THEN

            create_rev_term_LY_FLY ( p_last_period_id => l_last_period_id
                                    ,p_var_rent_id    => main_vr_rec.var_rent_id);

         /* Create reversal terms for cumulative volume = true-up. */
         /*ELSIF main_vr_rec.cumulative_vol = 'T'
         THEN

            create_rev_term_trueup ( p_last_period_id => l_last_period_id
                                    ,p_var_rent_id    => main_vr_rec.var_rent_id);*/

         END IF;
      END IF;

      /* update the bkpt_update_flag to 'Y for VR agreement */
      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y',
          sales_vol_update_flag = 'Y'
      WHERE var_rent_id  = main_vr_rec.var_rent_id;

   END LOOP;

   pnp_debug_pkg.debug ('pn_var_rent_pkg.process_vr_ext (-)');

EXCEPTION
   WHEN OTHERS THEN
      pnp_debug_pkg.debug ('Process_vr_early_term Error:'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_message := sqlerrm;
END;

-------------------------------------------------------------------------------
--  NAME         : process_vr_exp_con
--  DESCRIPTION  : This procedure is called from concurrent program 'PNVREXCO'.
--                 This procedure is responsible for calling process_vr_ext or
--                 process_vr_early_term according to the VR context
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :  p_lease_id, p_new_termn_date
--                       p_old_termn_date, p_setup_exp_context, p_vr_context
--                 OUT:  errbuf, retcode
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  01-JUN-06   piagrawa  o Created
--  20-NOV-06   Hareesha  o MTM Uptake - Added parameter p_rollover to consider
--                          VR expansion due to lease-rollover.
--  19-JAN-07   lbala     o Added call to delete_var_rent_agreeement to delete
--                          future dated VR agreements with no approved schedules
--  31-MAR-08   bifernan  o Bug 6524475: Proceed with this procedure only if the
--                          associated schedules and items request has completed
--                          successfully.
-------------------------------------------------------------------------------
PROCEDURE process_vr_exp_con (errbuf              OUT NOCOPY VARCHAR2,
                              retcode             OUT NOCOPY VARCHAR2,
                              p_lease_id          NUMBER,
                              p_lease_change_id   NUMBER,
                              p_old_term_date     VARCHAR2,
                              p_new_term_date     VARCHAR2,
                              p_vr_context        VARCHAR2,
                              p_setup_exp_context VARCHAR2,
                              p_rollover          VARCHAR2,
			      p_request_id        NUMBER)
IS
   l_old_term_date       DATE;
   l_new_term_date       DATE;
   l_ret_status          VARCHAR2(250);
   l_ret_message         VARCHAR2(250);
   l_old_date            DATE  := NULL;
   l_new_date            DATE  := NULL;
   l_max_lease_change_id NUMBER;
   INCORRECT_VR_CONTEXT_EXCEPTION     EXCEPTION;
   INCORRECT_VR_DATES_EXCEPTION       EXCEPTION;
   MISSING_CHANGE_ID_EXCEPTION        EXCEPTION;
   MISSING_SETUP_EXCEPTION            EXCEPTION;

   -- Bug 6524475
   l_interval			NUMBER := 60;
   l_max_wait			NUMBER := 0;
   l_request_phase		VARCHAR2(250);
   l_request_status		VARCHAR2(250);
   l_dev_request_phase		VARCHAR2(1000);
   l_dev_request_status		VARCHAR2(1000);
   l_request_status_mesg	VARCHAR2(1000);
   l_status			Boolean;
   SCH_ITEMS_FAILED_EXCEPTION	EXCEPTION;

   /* Fetches the max lease change id */
   CURSOR max_lease_change_id_cur IS
      SELECT max(lease_change_id) max_lease_change_id
      FROM pn_lease_details_history
      WHERE lease_id = p_lease_id;

   /* Fetches the old termination date for change id mentioned by the user */
   CURSOR old_term_date_cur IS
      SELECT lease_termination_date
      FROM   pn_lease_details_history
      WHERE  lease_id = p_lease_id
      AND    new_lease_change_id = p_lease_change_id;

   /* Fetches the new termination date for change id mentioned by the user */
   CURSOR new_term_date_cur IS
      SELECT lease_termination_date
      FROM   pn_lease_details_history
      WHERE  lease_id = p_lease_id
      AND    lease_change_id = p_lease_change_id;

   /* Fetches the current termination date from lease details table */
   CURSOR lease_details_cur IS
     SELECT lease_termination_date
     FROM pn_lease_details_all
     WHERE lease_change_id = p_lease_change_id;

BEGIN
   pnp_debug_pkg.log('pn_var_rent_pkg.process_vr_exp_con +Start+ (+)');
   pnp_debug_pkg.log('Lease_ID                : '||p_lease_id);
   pnp_debug_pkg.log('Lease_Chang_ID          : '||p_lease_change_id);
   pnp_debug_pkg.log('Old Termination date    : '||p_old_term_date);
   pnp_debug_pkg.log('New Termination date    : '||p_new_term_date);
   pnp_debug_pkg.log('Variable Rent Context   : '||p_vr_context);
   pnp_debug_pkg.log('Setup Expansion Context : '||p_setup_exp_context);

   -- Bug 6524475
   IF p_request_id IS NOT NULL AND p_request_id <> 0 THEN
       l_status := fnd_concurrent.wait_for_request(p_request_id, l_interval, l_max_wait,
					l_request_phase, l_request_status,
					l_dev_request_phase, l_dev_request_status,
					l_request_status_mesg);
       IF l_status = TRUE THEN
           IF l_dev_request_phase <> 'COMPLETE' OR l_dev_request_status <> 'NORMAL' THEN
               RAISE SCH_ITEMS_FAILED_EXCEPTION;
           END IF;
       ELSE
           RAISE SCH_ITEMS_FAILED_EXCEPTION;
       END IF;
   END IF;

   l_old_term_date := fnd_date.canonical_to_date(p_old_term_date);
   l_new_term_date := fnd_date.canonical_to_date(p_new_term_date);

   IF p_rollover IS NULL THEN

      /* Fetch the max lease change id for this lease. It will always
         return some value if amendment done for a lease */
      FOR rec IN max_lease_change_id_cur LOOP
         l_max_lease_change_id := rec.max_lease_change_id;
      END LOOP;

      /* Throw an exception if the user does not specify a lease change id
         in case of amended lease. l_max_lease_change_id will be NULL for
         draft leases.*/
      IF  l_max_lease_change_id IS NOT NULL AND p_lease_change_id IS NULL THEN

         RAISE MISSING_CHANGE_ID_EXCEPTION;

      ELSIF (l_max_lease_change_id IS NOT NULL AND p_lease_change_id IS NOT NULL) THEN

         /* Fetch the old termination date from pn_lease_details_history tables
            for the last amendment */
         FOR rec IN old_term_date_cur LOOP
            l_old_date := rec.lease_termination_date;
         END LOOP;

         /* Fetch the new termination date from pn_lease_details_history table */
         FOR new_term_date_rec IN new_term_date_cur LOOP
            l_new_date := new_term_date_rec.lease_termination_date;
         END LOOP;

         /* If new termination date is null that is the record for the mentioned
            change id is not present in the lease details history table then it
            implies that it is the current lease record. Thus fetch the date from
            pn_lease_details_all table */
         IF l_new_date IS NULL THEN

            FOR lease_details_rec IN lease_details_cur LOOP
               l_new_date := lease_details_rec.lease_termination_date;
            END LOOP;

         END IF;

         /* Raise an exception that the dates entered by the user do not match with
            that in the database */
         /*IF (l_old_date <> l_old_term_date) OR (l_new_date <> l_new_term_date ) THEN
            pnp_debug_pkg.log('Throwing exception ....');
            RAISE INCORRECT_VR_DATES_EXCEPTION ;
         END IF;*/

      END IF;
    END IF;


   /* Check if new termination date is same as old termination date */
   IF (l_old_term_date <> l_new_term_date) THEN

      pnp_debug_pkg.log('New termination date is not equal to old termination date');
      /* Check if the dates and vr context are in sync i.e. if new termination date is less than old termination
         date then vr context should be 'CON' and if the new termination date is greater than old termination
         date then vr context should be 'EXP'. If this is not the case then throw an exception */
      IF (l_new_term_date < l_old_term_date) AND p_vr_context = 'CON' THEN

         pnp_debug_pkg.log('Deleting VR agreements starting after new termination date');
         PN_VAR_RENTS_PKG.delete_var_rent_agreement(p_lease_id        => p_lease_id ,
                                                    p_termination_dt  => l_new_term_date);

         pnp_debug_pkg.log('Calling VR contraction ....');
         process_vr_early_term ( p_lease_id        => p_lease_id
                                ,p_var_rent_id     => NULL
                                ,p_new_termn_date  => l_new_term_date
                                ,p_old_termn_date  => l_old_term_date
                                ,x_return_status   => l_ret_status
                                ,x_return_message  => l_ret_message);

      ELSIF (l_new_term_date > l_old_term_date) AND p_vr_context = 'EXP' THEN

         IF p_setup_exp_context IS NULL THEN
            pnp_debug_pkg.log('Throwing exception ....');
            RAISE MISSING_SETUP_EXCEPTION ;
         ELSE
            pnp_debug_pkg.log('Calling VR expansion ....');
            process_vr_ext (  p_lease_id        => p_lease_id
                             ,p_var_rent_id     => NULL
                             ,p_new_termn_date  => l_new_term_date
                             ,p_old_termn_date  => l_old_term_date
                             ,p_extend_setup    => p_setup_exp_context
                             ,x_return_status   => l_ret_status
                             ,x_return_message  => l_ret_message);
         END IF;

      ELSIF (((l_new_term_date < l_old_term_date) AND p_vr_context <> 'CON') OR
             ((l_new_term_date > l_old_term_date) AND p_vr_context <> 'EXP')) THEN

         pnp_debug_pkg.log('Throwing exception ....');
         RAISE INCORRECT_VR_CONTEXT_EXCEPTION ;
      END IF;

   END IF;

   pnp_debug_pkg.log('pn_var_rent_pkg.process_vr_exp_con +End+ (+)');

EXCEPTION
   WHEN SCH_ITEMS_FAILED_EXCEPTION THEN
      fnd_message.set_name ('PN', 'PN_SCH_ITEMS_REQ_FAILED');
      fnd_message.set_token ('REQ_NUM',p_request_id);
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;
   WHEN INCORRECT_VR_CONTEXT_EXCEPTION THEN
      fnd_message.set_name ('PN', 'INCORRECT_VR_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;
   WHEN INCORRECT_VR_DATES_EXCEPTION THEN
      fnd_message.set_name ('PN', 'INCORRECT_VR_DATES');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;
   WHEN MISSING_CHANGE_ID_EXCEPTION THEN
      fnd_message.set_name ('PN', 'MISSING_CHANGE_ID');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;
   WHEN MISSING_SETUP_EXCEPTION THEN
      fnd_message.set_name ('PN', 'MISSING_SETUP_CONTEXT');
      errbuf := fnd_message.get;
      pnp_debug_pkg.put_log_msg (errbuf);
      retcode := 2;
   WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      Retcode := 2;
      ROLLBACK;
END;


-------------------------------------------------------------------------------
--  NAME         : copy_bkpt_main_to_setup
--  DESCRIPTION  : This procedure is called from concurrent program 'PNVRCASB'.
--                 This procedure will help the existing users to copy the
--                 lines and breakpoint definition main UI to SETUP UI
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN :
--
--                 OUT:  errbuf, retcode
--
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  18-JAN-07 pikhar  o Created
--  29-MAR-07 pikhar  o Bug 5959082.Populated line defaults start and end dates
-------------------------------------------------------------------------------

PROCEDURE copy_bkpt_main_to_setup (errbuf              OUT NOCOPY VARCHAR2,
                                   retcode             OUT NOCOPY VARCHAR2,
                                   p_prop_id           IN NUMBER,
                                   p_loc_id            IN NUMBER,
                                   p_lease_id          IN NUMBER,
                                   p_var_rent_id       IN NUMBER)
IS

TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_sales_type_code       pn_var_lines_all.sales_type_code%TYPE;
l_item_category_code    pn_var_lines_all.item_category_code%TYPE;
l_lease_id              NUMBER        := NULL;
l_prop_id               NUMBER        := NULL;
l_loc_id                NUMBER        := NULL;
l_var_rent_id           NUMBER        := NULL;
l_rowId_lines           VARCHAR2(30)  := NULL;
l_lineitemId            NUMBER        := NULL;
l_lineitemNum           NUMBER        := NULL;
l_rowid_line_defaults   VARCHAR2(30)  := NULL;
l_linedefaultid         NUMBER        := NULL;
l_linedefNum            NUMBER        := NULL;
l_period_id             NUMBER        := NULL;
l_bkhd_rowid            VARCHAR2(30)  := NULL;
l_bkhddefault_id        NUMBER        := NULL;
l_rowid_constr_defaults VARCHAR2(30)  := NULL;
l_constrdefaultid       NUMBER        := NULL;
l_constrdefNum          NUMBER        := NULL;
l_linenum               NUMBER        := NULL;
l_bkpt_header_id        NUMBER        := NULL;
l_bkdt_rowId            VARCHAR2(30)  := NULL;
l_bkdtdefaultId         NUMBER        := NULL;
l_bkdtdefaultNum        NUMBER        := NULL;
l_date                  DATE          := NULL;
l_invalid_agr           VARCHAR2(30)  := NULL;
l_rent_num              VARCHAR2(30)  := NULL;

l_varent_tab            NUM_TBL;


/* Cursor to get all var_rents for the given property */
CURSOR varent_prop_cur (p_prop_id IN NUMBER)
IS
SELECT DISTINCT var.var_rent_id
from   pn_var_rents_all var
where  var.lease_id IN( SELECT distinct lease_id
                        FROM ( SELECT lease_id
                               FROM pn_tenancies_all
                               WHERE location_id in (SELECT location_id
                                                     FROM pn_locations_all
                                                     WHERE property_id = p_prop_id)
                               UNION
                               SELECT lease_id
                               FROM pn_leases_all
                               WHERE location_id in (SELECT location_id
                                                     FROM pn_locations_all
                                                     WHERE property_id = p_prop_id)));


/* Cursor to get all var_rents for the given location */
CURSOR varent_loc_cur(p_loc_id IN NUMBER)
IS
   SELECT DISTINCT var.var_rent_id
   FROM   pn_var_rents_all var
   WHERE  var.lease_id IN (SELECT lease_id
                           FROM (SELECT lease_id
                                 FROM pn_tenancies_all
                                 WHERE location_id = p_loc_id
                                 UNION
                                 SELECT lease_id
                                 FROM pn_leases_all
                                 WHERE location_id = p_loc_id));


/* Cursor to get all var_rents for the given lease */
CURSOR varent_lease_cur(p_lease_id IN NUMBER)
IS
   SELECT DISTINCT var.var_rent_id
   FROM   pn_var_rents_all var
   WHERE  var.lease_id = p_lease_id;


/* Cursor used to fetch distinct periods */
CURSOR periods_cur(p_var_rent_id NUMBER) IS
   SELECT DISTINCT per.period_id period_id,
          var.rent_num rent_num
   FROM   pn_var_periods_all per,
          pn_var_rents_all var
   WHERE  per.var_rent_id = p_var_rent_id
   AND    var.var_rent_id = p_var_rent_id;


/* Cursor used to fetch distinct lines */
CURSOR lines_cur(p_var_rent_id NUMBER) IS
   SELECT DISTINCT
          sales_type_code,
          item_category_code,
          org_id
   FROM   pn_var_lines_all
   WHERE  var_rent_id = p_var_rent_id;


/* Cursor used to count if a give periods has more than one occurance of a line */
CURSOR lines_count_cur(p_per_id NUMBER,
                       p_sales_type_code VARCHAR2,
                       p_item_category_code VARCHAR2) IS
  SELECT count(*) lines_count
  FROM pn_var_lines_all
  WHERE sales_type_code = p_sales_type_code
  AND item_category_code = p_item_category_code
  AND period_id = p_per_id;


/* Cursor used to fetch periods which does not have passed line */
CURSOR no_per_lines_exists(p_var_rent_id NUMBER,
                           p_sales_type_code VARCHAR2,
                           p_item_category_code VARCHAR2) IS
   SELECT per.period_id, per.org_id
   FROM   pn_var_periods_all per
   WHERE  per.period_id not in (
      SELECT lines.period_id
      FROM   pn_var_lines_all lines
      WHERE  lines.var_rent_id = p_var_rent_id
      AND    nvl(lines.sales_type_code,'-1') = nvl(p_sales_type_code,'-1')
      AND    nvl(lines.item_category_code,'-1') = nvl(p_item_category_code,'-1'))
   AND var_rent_id =  p_var_rent_id ;


/* Cursor used to fetch breakpoint header */
CURSOR bkhd_cur(p_var_rent_id NUMBER) IS
   SELECT bkpt.bkpt_header_id bkpt_header_id,
          bkpt.bkhd_start_date start_date,
          bkpt.bkhd_end_date end_date,
          bkpt.break_type break_type,
          bkpt.base_rent_type base_rent_type,
          bkpt.natural_break_rate natural_break_rate,
          bkpt.base_rent base_rent,
          bkpt.breakpoint_type breakpoint_type,
          bkpt.org_id org_id,
          bkpt.attribute_category attribute_category,
          bkpt.attribute1 attribute1,
          bkpt.attribute2 attribute2,
          bkpt.attribute3 attribute3,
          bkpt.attribute4 attribute4,
          bkpt.attribute5 attribute5,
          bkpt.attribute6 attribute6,
          bkpt.attribute7 attribute7,
          bkpt.attribute8 attribute8,
          bkpt.attribute9 attribute9,
          bkpt.attribute10 attribute10,
          bkpt.attribute11 attribute11,
          bkpt.attribute12 attribute12,
          bkpt.attribute13 attribute13,
          bkpt.attribute14 attribute14,
          bkpt.attribute15 attribute15,
          lines.line_default_id line_default_id
   FROM   pn_var_bkpts_head_all bkpt,
          pn_var_lines_all lines
   WHERE  bkpt.var_rent_id = p_var_rent_id
   AND    bkpt.line_item_id = lines.line_item_id;


/* Cursor used to fetch breakpoint details */
CURSOR bkdt_cur(p_var_rent_id NUMBER) IS
   SELECT bkdt.bkpt_detail_id bkpt_detail_id,
          bkdt.bkpt_start_date bkpt_start_date,
          bkdt.bkpt_end_date bkpt_end_date,
          bkdt.period_bkpt_vol_start period_bkpt_vol_start,
          bkdt.period_bkpt_vol_end period_bkpt_vol_end,
          bkdt.group_bkpt_vol_start group_bkpt_vol_start,
          bkdt.group_bkpt_vol_end group_bkpt_vol_end,
          bkdt.bkpt_rate bkpt_rate,
          bkdt.comments comments ,
          bkdt.attribute_category attribute_category,
          bkdt.attribute1 attribute1,
          bkdt.attribute2 attribute2,
          bkdt.attribute3 attribute3,
          bkdt.attribute4 attribute4,
          bkdt.attribute5 attribute5,
          bkdt.attribute6 attribute6,
          bkdt.attribute7 attribute7,
          bkdt.attribute8 attribute8,
          bkdt.attribute9 attribute9,
          bkdt.attribute10 attribute10,
          bkdt.attribute11 attribute11,
          bkdt.attribute12 attribute12,
          bkdt.attribute13 attribute13,
          bkdt.attribute14 attribute14,
          bkdt.attribute15 attribute15,
          bkdt.org_id org_id,
          bkdt.annual_basis_amount annual_basis_amount,
          bkhd.bkhd_default_id bkhd_default_id
   FROM   pn_var_bkpts_det_all bkdt,
          pn_var_bkpts_head_all bkhd
   WHERE  bkdt.var_rent_id = p_var_rent_id
   AND    bkdt.bkpt_header_id = bkhd.bkpt_header_id;


/* Cursor used to fetch constraints details */
CURSOR constr_cur(p_var_rent_id NUMBER) IS
   SELECT  cons.constraint_id
          ,cons.constraint_num
          ,cons.last_update_date
          ,cons.last_updated_by
          ,cons.creation_date
          ,cons.created_by
          ,cons.last_update_login
          ,cons.period_id
          ,cons.constr_cat_code
          ,cons.type_code
          ,cons.amount
          ,cons.comments
          ,cons.attribute_category
          ,cons.attribute1
          ,cons.attribute2
          ,cons.attribute3
          ,cons.attribute4
          ,cons.attribute5
          ,cons.attribute6
          ,cons.attribute7
          ,cons.attribute8
          ,cons.attribute9
          ,cons.attribute10
          ,cons.attribute11
          ,cons.attribute12
          ,cons.attribute13
          ,cons.attribute14
          ,cons.attribute15
          ,cons.org_id
          ,cons.agreement_template_id
          ,cons.constr_template_id
          ,cons.constr_default_id
          ,cons.constr_start_date
          ,cons.constr_end_date
   FROM   pn_var_constraints_all cons,
          pn_var_periods_all per
   WHERE  per.var_rent_id = p_var_rent_id
   AND    cons.period_id = per.period_id;


/* Exceptions */
BAD_CALL_EXCEPTION   EXCEPTION;


BEGIN

   l_varent_tab.DELETE;

   IF p_var_rent_id IS NOT NULL THEN

      l_varent_tab(1) := p_var_rent_id;

   ELSIF p_lease_id IS NOT NULL THEN

      l_lease_id := p_lease_id;
      OPEN  varent_lease_cur(p_lease_id => l_lease_id);
      FETCH varent_lease_cur BULK COLLECT INTO l_varent_tab;
      CLOSE varent_lease_cur;

   ELSIF p_loc_id IS NOT NULL THEN

      l_loc_id := p_loc_id;
      OPEN  varent_loc_cur(p_loc_id => l_loc_id);
      FETCH varent_loc_cur BULK COLLECT INTO l_varent_tab;
      CLOSE varent_loc_cur;

   ELSIF p_prop_id IS NOT NULL THEN

      l_prop_id := p_prop_id;
      OPEN  varent_prop_cur(p_prop_id => l_prop_id);
      FETCH varent_prop_cur BULK COLLECT INTO l_varent_tab;
      CLOSE varent_prop_cur;

   ELSE

      RAISE BAD_CALL_EXCEPTION;

   END IF;

   IF l_varent_tab.count > 0 THEN
      <<outer>>
      FOR var_rec in l_varent_tab.FIRST .. l_varent_tab.LAST
      LOOP

         l_var_rent_id := l_varent_tab(var_rec);
         l_rent_num    := NULL;
         l_invalid_agr := NULL;

         IF l_var_rent_id IS NOT NULL THEN

            SELECT rent_num
            INTO l_rent_num
            FROM pn_var_rents_all
            WHERE var_rent_id = l_var_rent_id;

            /* Checking if the var rent agreement has a period with two or more similar lines */

            FOR per_rec IN periods_cur(l_var_rent_id) LOOP
                --l_rent_num := per_rec.rent_num;

                FOR lines_rec  IN lines_cur(l_var_rent_id) LOOP

                   l_sales_type_code := lines_rec.sales_type_code;
                   l_item_category_code := lines_rec.item_category_code;

                   FOR lines_count_rec  IN lines_count_cur(per_rec.period_id, l_sales_type_code,l_item_category_code) LOOP

                      IF lines_count_rec.lines_count > 1 THEN
                         l_invalid_agr := 'Y'; /* similar lines found */
                         --Fnd_File.Put_Line ( Fnd_File.OutPut,'     ---------------------------------------------------------------------------');
                         --Fnd_File.Put_Line ( Fnd_File.OutPut,'      Agreement ' || per_rec.rent_num || ' has two or more similar lines in same period and hence ');
                         --Fnd_File.Put_Line ( Fnd_File.OutPut,'      cannot be processed. You will need to recreate this agreement manually.');
                         --Fnd_File.Put_Line ( Fnd_File.OutPut,'     ---------------------------------------------------------------------------');
                         pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');
                         pnp_debug_pkg.log ('      Agreement ' || per_rec.rent_num || ' has two or more similar lines in same period and hence ');
                         pnp_debug_pkg.log ('      cannot be processed. You will need to recreate this agreement manually.');
                         pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');

                         EXIT outer;
                      END IF;
                   END LOOP;

                END LOOP;
            END LOOP;

            /* Completed Checking if the var rent agreement has a period with two or more similar lines */


            IF (nvl(l_invalid_agr,'N') <> 'Y') THEN

               SELECT sysdate
               INTO l_date
               FROM dual;

               DELETE FROM PN_VAR_LINE_DEFAULTS_ALL
               WHERE var_rent_id = l_var_rent_id;

               DELETE FROM PN_VAR_BKHD_DEFAULTS_ALL
               WHERE var_rent_id = l_var_rent_id;

               DELETE FROM PN_VAR_BKDT_DEFAULTS_ALL
               WHERE var_rent_id = l_var_rent_id;

               DELETE FROM PN_VAR_CONSTR_DEFAULTS_ALL
               WHERE var_rent_id = l_var_rent_id;

               l_sales_type_code    := NULL;
               l_item_category_code := NULL;

               /* Inserting line into lines defaults table and populating lines with the line default id */

               /* Fetch distinct line items from the VR and then populate them into defaults table*/

               FOR lines_rec  IN lines_cur(l_var_rent_id) LOOP

                  l_sales_type_code     := lines_rec.sales_type_code;
                  l_item_category_code  := lines_rec.item_category_code;

                  l_rowid_line_defaults := NULL;
                  l_linedefaultid       := NULL;
                  l_linedefNum          := NULL;

                  PN_VAR_LINE_DEFAULTS_PKG.INSERT_ROW(
                      X_ROWID                 => l_rowid_line_defaults,
                      X_LINE_DEFAULT_ID       => l_linedefaultid,
                      X_LINE_NUM              => l_linedefNum,
                      X_VAR_RENT_ID           => l_var_rent_id,
                      X_SALES_TYPE_CODE       => l_sales_type_code,
                      X_ITEM_CATEGORY_CODE    => l_item_category_code,
                      X_LINE_TEMPLATE_ID      => NULL,
                      X_AGREEMENT_TEMPLATE_ID => NULL,
                      X_LINE_START_DATE       => NULL,
                      X_LINE_END_DATE         => NULL,
                      X_PROCESSED_FLAG        => NULL,
                      X_CREATION_DATE         => l_date,
                      X_CREATED_BY            => -1,
                      X_LAST_UPDATE_DATE      => l_date,
                      X_LAST_UPDATED_BY       => -1,
                      X_LAST_UPDATE_LOGIN     => -1,
                      X_ORG_ID                => lines_rec.org_id,
                      X_ATTRIBUTE_CATEGORY    => NULL,
                      X_ATTRIBUTE1            => NULL,
                      X_ATTRIBUTE2            => NULL,
                      X_ATTRIBUTE3            => NULL,
                      X_ATTRIBUTE4            => NULL,
                      X_ATTRIBUTE5            => NULL,
                      X_ATTRIBUTE6            => NULL,
                      X_ATTRIBUTE7            => NULL,
                      X_ATTRIBUTE8            => NULL,
                      X_ATTRIBUTE9            => NULL,
                      X_ATTRIBUTE10           => NULL,
                      X_ATTRIBUTE11           => NULL,
                      X_ATTRIBUTE12           => NULL,
                      X_ATTRIBUTE13           => NULL,
                      X_ATTRIBUTE14           => NULL,
                      X_ATTRIBUTE15           => NULL
                      );

                   /* check nvl condition*/
                   /* Insert the line item into pn_var_lines_all for thoses
                      periods where this line does not exists*/


                   FOR per_rec IN no_per_lines_exists(l_var_rent_id,
                                                      l_sales_type_code,
                                                      l_item_category_code) LOOP

                   l_rowId_lines  := NULL;
                   l_lineitemId   := NULL;
                   l_lineitemNum  := NULL;

                   PN_VAR_LINES_PKG.INSERT_ROW (
                            X_ROWID                 => l_rowId_lines,
                            X_LINE_ITEM_ID          => l_lineitemId,
                            X_LINE_ITEM_NUM         => l_lineitemNum,
                            X_PERIOD_ID             => per_rec.period_id,
                            X_SALES_TYPE_CODE       => l_sales_type_code,
                            X_ITEM_CATEGORY_CODE    => l_item_category_code,
                            X_COMMENTS              => NULL,
                            X_ATTRIBUTE_CATEGORY    => NULL,
                            X_ATTRIBUTE1            => NULL,
                            X_ATTRIBUTE2            => NULL,
                            X_ATTRIBUTE3            => NULL,
                            X_ATTRIBUTE4            => NULL,
                            X_ATTRIBUTE5            => NULL,
                            X_ATTRIBUTE6            => NULL,
                            X_ATTRIBUTE7            => NULL,
                            X_ATTRIBUTE8            => NULL,
                            X_ATTRIBUTE9            => NULL,
                            X_ATTRIBUTE10           => NULL,
                            X_ATTRIBUTE11           => NULL,
                            X_ATTRIBUTE12           => NULL,
                            X_ATTRIBUTE13           => NULL,
                            X_ATTRIBUTE14           => NULL,
                            X_ATTRIBUTE15           => NULL,
                            X_CREATION_DATE         => l_date,
                            X_CREATED_BY            => -1,
                            X_LAST_UPDATE_DATE      => l_date,
                            X_LAST_UPDATED_BY       => -1,
                            X_LAST_UPDATE_LOGIN     => -1,
                            X_ORG_ID                => per_rec.org_id,
                            X_VAR_RENT_ID           => l_var_rent_id,
                            X_LINE_TEMPLATE_ID      => NULL,
                            X_AGREEMENT_TEMPLATE_ID => NULL,
                            X_LINE_DEFAULT_ID       => l_linedefaultid
                       );


                   END LOOP; /* per_rec*/



                   UPDATE pn_var_lines_all
                   SET    line_default_id = l_linedefaultid
                   WHERE  var_rent_id = l_var_rent_id
                   AND    nvl(sales_type_code,'-1') = nvl(l_sales_type_code,'-1')
                   AND    nvl(item_category_code,'-1') = nvl(l_item_category_code,'-1');

               END LOOP;


               /* Completed Inserting line into lines defaults table and
                  populating lines with the line default id */


               /* Inserting into breakpoint Header defaults and  populating
                  breakpoints with the breakpoint default id */

               FOR bkpt_rec IN bkhd_cur(l_var_rent_id) LOOP

                 l_bkhd_rowid      := NULL;
                 l_bkhddefault_id  := NULL;
                 l_linenum         := NULL;

                 IF bkpt_rec.line_default_id IS NOT NULL THEN

                     PN_VAR_BKHD_DEFAULTS_PKG.INSERT_ROW(
                          X_ROWID                 => l_bkhd_rowid,
                          X_BKHD_DEFAULT_ID       => l_bkhddefault_id,
                          X_BKHD_DETAIL_NUM       => l_linenum,
                          X_LINE_DEFAULT_ID       => bkpt_rec.line_default_id,
                          X_BKPT_HEAD_TEMPLATE_ID => NULL,
                          X_AGREEMENT_TEMPLATE_ID => NULL,
                          X_BKHD_START_DATE       => bkpt_rec.start_date,
                          X_BKHD_END_DATE         => bkpt_rec.end_date,
                          X_BREAK_TYPE            => bkpt_rec.break_type,
                          X_BASE_RENT_TYPE        => bkpt_rec.base_rent_type,
                          X_NATURAL_BREAK_RATE    => bkpt_rec.natural_break_rate,
                          X_BASE_RENT             => bkpt_rec.base_rent,
                          X_BREAKPOINT_TYPE       => bkpt_rec.breakpoint_type,
                          X_BREAKPOINT_LEVEL      => NULL,
                          X_PROCESSED_FLAG        => NULL,
                          X_VAR_RENT_ID           => l_var_rent_id,
                          X_CREATION_DATE         => l_date,
                          X_CREATED_BY            => -1,
                          X_LAST_UPDATE_DATE      => l_date,
                          X_LAST_UPDATED_BY       => -1,
                          X_LAST_UPDATE_LOGIN     => -1,
                          X_ORG_ID                => bkpt_rec.org_id,
                          X_ATTRIBUTE_CATEGORY    => bkpt_rec.ATTRIBUTE_CATEGORY,
                          X_ATTRIBUTE1            => bkpt_rec.ATTRIBUTE1,
                          X_ATTRIBUTE2            => bkpt_rec.ATTRIBUTE2,
                          X_ATTRIBUTE3            => bkpt_rec.ATTRIBUTE3,
                          X_ATTRIBUTE4            => bkpt_rec.ATTRIBUTE4,
                          X_ATTRIBUTE5            => bkpt_rec.ATTRIBUTE5,
                          X_ATTRIBUTE6            => bkpt_rec.ATTRIBUTE6,
                          X_ATTRIBUTE7            => bkpt_rec.ATTRIBUTE7,
                          X_ATTRIBUTE8            => bkpt_rec.ATTRIBUTE8,
                          X_ATTRIBUTE9            => bkpt_rec.ATTRIBUTE9,
                          X_ATTRIBUTE10           => bkpt_rec.ATTRIBUTE10,
                          X_ATTRIBUTE11           => bkpt_rec.ATTRIBUTE11,
                          X_ATTRIBUTE12           => bkpt_rec.ATTRIBUTE12,
                          X_ATTRIBUTE13           => bkpt_rec.ATTRIBUTE13,
                          X_ATTRIBUTE14           => bkpt_rec.ATTRIBUTE14,
                          X_ATTRIBUTE15           => bkpt_rec.ATTRIBUTE15
                          );

                     UPDATE pn_var_bkpts_head_all
                     SET bkhd_default_id =  l_bkhddefault_id
                     WHERE bkpt_header_id = bkpt_rec.bkpt_header_id;

                 END IF;

                 UPDATE pn_var_line_defaults_all
                 SET line_start_date = (select min(bkhd_start_date)
                                        from pn_var_bkhd_defaults_all
                                        where line_default_id = bkpt_rec.line_default_id)
                 WHERE line_default_id = bkpt_rec.line_default_id;


                 UPDATE pn_var_line_defaults_all
                 SET line_end_date = (select max(bkhd_end_date)
                                      from pn_var_bkhd_defaults_all
                                      where line_default_id = bkpt_rec.line_default_id)
                 WHERE line_default_id = bkpt_rec.line_default_id;



               END LOOP; /*bkpt cursor*/

               /* Completed Inserting breakpoints into breakpoint defaults table and
                  populating breakpoints with the breakpoint default id */



               /* Inserting into breakpoint detail defaults and populating breakpoints
                  details with the breakpoint detail default id */


               FOR bkdt_rec IN bkdt_cur(l_var_rent_id) LOOP

               l_bkdt_rowId      := NULL;
               l_bkdtdefaultId   := NULL;
               l_bkdtdefaultNum  := NULL;

               IF bkdt_rec.bkhd_default_id IS NOT NULL THEN
                  PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW(
                      X_ROWID                  => l_bkdt_rowId,
                      X_BKDT_DEFAULT_ID        => l_bkdtdefaultId,
                      X_BKDT_DETAIL_NUM        => l_bkdtdefaultNum,
                      X_BKHD_DEFAULT_ID        => bkdt_rec.BKHD_DEFAULT_ID,
                      X_BKDT_START_DATE        => bkdt_rec.BKPT_START_DATE,
                      X_BKDT_END_DATE          => bkdt_rec.BKPT_END_DATE,
                      X_PERIOD_BKPT_VOL_START  => bkdt_rec.PERIOD_BKPT_VOL_START,
                      X_PERIOD_BKPT_VOL_END    => bkdt_rec.PERIOD_BKPT_VOL_END,
                      X_GROUP_BKPT_VOL_START   => bkdt_rec.GROUP_BKPT_VOL_START,
                      X_GROUP_BKPT_VOL_END     => bkdt_rec.GROUP_BKPT_VOL_END,
                      X_BKPT_RATE              => bkdt_rec.BKPT_RATE,
                      X_PROCESSED_FLAG         => NULL,
                      X_VAR_RENT_ID            => l_var_rent_id,
                      X_CREATION_DATE          => l_date,
                      X_CREATED_BY             => -1,
                      X_LAST_UPDATE_DATE       => l_date,
                      X_LAST_UPDATED_BY        => -1,
                      X_LAST_UPDATE_LOGIN      => -1,
                      X_ORG_ID                 => bkdt_rec.org_id,
                      X_ANNUAL_BASIS_AMOUNT    => bkdt_rec.ANNUAL_BASIS_AMOUNT,
                      X_ATTRIBUTE_CATEGORY     => bkdt_rec.ATTRIBUTE_CATEGORY,
                      X_ATTRIBUTE1             => bkdt_rec.ATTRIBUTE1,
                      X_ATTRIBUTE2             => bkdt_rec.ATTRIBUTE2,
                      X_ATTRIBUTE3             => bkdt_rec.ATTRIBUTE3,
                      X_ATTRIBUTE4             => bkdt_rec.ATTRIBUTE4,
                      X_ATTRIBUTE5             => bkdt_rec.ATTRIBUTE5,
                      X_ATTRIBUTE6             => bkdt_rec.ATTRIBUTE6,
                      X_ATTRIBUTE7             => bkdt_rec.ATTRIBUTE7,
                      X_ATTRIBUTE8             => bkdt_rec.ATTRIBUTE8,
                      X_ATTRIBUTE9             => bkdt_rec.ATTRIBUTE9,
                      X_ATTRIBUTE10            => bkdt_rec.ATTRIBUTE10,
                      X_ATTRIBUTE11            => bkdt_rec.ATTRIBUTE11,
                      X_ATTRIBUTE12            => bkdt_rec.ATTRIBUTE12,
                      X_ATTRIBUTE13            => bkdt_rec.ATTRIBUTE13,
                      X_ATTRIBUTE14            => bkdt_rec.ATTRIBUTE14,
                      X_ATTRIBUTE15            => bkdt_rec.ATTRIBUTE15
                      );

                     UPDATE pn_var_bkpts_det_all
                     SET BKDT_DEFAULT_ID =  l_bkdtdefaultId
                     WHERE BKPT_DETAIL_ID = bkdt_rec.bkpt_detail_id;

                  END IF;

               END LOOP; /*bkdt cursor*/

               /* Completed Inserting breakpoint detail into breakpoint defaults table
                  and populating breakpoints with the breakpoint default id */

               /* Inserting into constraints defaults and populating constraints
                  details with the constraint detail default id */


               FOR constr_rec IN constr_cur(l_var_rent_id) LOOP

                  l_rowid_constr_defaults := NULL;
                  l_constrdefaultid       := NULL;
                  l_constrdefNum          := NULL;

                  PN_VAR_CONSTR_DEFAULTS_PKG.INSERT_ROW
                   (
                   X_ROWID                 => l_rowid_constr_defaults,
                   X_CONSTR_DEFAULT_ID     => l_constrdefaultid,
                   X_CONSTR_DEFAULT_NUM    => l_constrdefNum,
                   X_VAR_RENT_ID           => l_var_rent_id,
                   X_AGREEMENT_TEMPLATE_ID => NULL,
                   X_CONSTR_TEMPLATE_ID    => NULL,
                   X_CONSTR_START_DATE     => constr_rec.constr_start_date,
                   X_CONSTR_END_DATE       => constr_rec.constr_end_date,
                   X_CONSTR_CAT_CODE       => constr_rec.constr_cat_code,
                   X_TYPE_CODE             => constr_rec.type_code,
                   X_AMOUNT                => constr_rec.amount,
                   X_CREATION_DATE         => l_date,
                   X_CREATED_BY            => -1,
                   X_LAST_UPDATE_DATE      => l_date,
                   X_LAST_UPDATED_BY       => -1,
                   X_LAST_UPDATE_LOGIN     => -1,
                   X_ORG_ID                => constr_rec.org_id,
                   X_ATTRIBUTE_CATEGORY    => NULL,
                   X_ATTRIBUTE1            => NULL,
                   X_ATTRIBUTE2            => NULL,
                   X_ATTRIBUTE3            => NULL,
                   X_ATTRIBUTE4            => NULL,
                   X_ATTRIBUTE5            => NULL,
                   X_ATTRIBUTE6            => NULL,
                   X_ATTRIBUTE7            => NULL,
                   X_ATTRIBUTE8            => NULL,
                   X_ATTRIBUTE9            => NULL,
                   X_ATTRIBUTE10           => NULL,
                   X_ATTRIBUTE11           => NULL,
                   X_ATTRIBUTE12           => NULL,
                   X_ATTRIBUTE13           => NULL,
                   X_ATTRIBUTE14           => NULL,
                   X_ATTRIBUTE15           => NULL
                   );

                   UPDATE pn_var_constraints_all
                   SET    constr_default_id = l_constrdefaultid
                   WHERE    constraint_id = constr_rec.constraint_id;


               END LOOP; /*constr_rec*/


               /* Completed Inserting constraints into constraint defaults table and
                  populating constraints with the constraints default id */

               pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');
               pnp_debug_pkg.log ('      Agreement ' || l_rent_num || ' has been Updated');
               pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');

            END IF;

         END IF;
      END LOOP;
   ELSE
      pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');
      pnp_debug_pkg.log ('      There is no Variable Rent Agreement with given search criteria');
      pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');
   END IF;

EXCEPTION
      WHEN BAD_CALL_EXCEPTION THEN
         pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');
         pnp_debug_pkg.log ('      Input to the program is invalid');
         pnp_debug_pkg.log ('     ---------------------------------------------------------------------------');

END copy_bkpt_main_to_setup;

/*===========================================================================+
| FUNCTION
|    find_if_inv_exp
|
| DESCRIPTION
|    Finds if forecasted terms have been approved for an invoice date for
|    this variable rent.
|
| SCOPE - PUBLIC
|
| EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:
|                    p_var_rent_id, p_invoice_date
|
|              OUT:
|
| RETURNS    : None
|
| NOTES      : Finds if forecasted terms have been approved for an invoice
|               date for this variable rent.
|
| MODIFICATION HISTORY
|
|  05-03-2007  piagrawa o Created
+===========================================================================*/

FUNCTION find_if_inv_exp (p_var_rent_id NUMBER, p_invoice_date DATE) RETURN NUMBER IS

l_inv_exp NUMBER;

BEGIN

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_INV_EXP (+)');

  SELECT 1
  INTO   l_inv_exp
  FROM   dual
  WHERE  EXISTS ( SELECT inv.var_rent_inv_id
                  FROM   pn_var_rent_inv_all inv
                  WHERE  inv.var_rent_id = p_var_rent_id
                  AND    inv.invoice_date =  p_invoice_date
                  AND    (forecasted_exp_code = 'Y'));

  RETURN l_inv_exp;

  pnp_debug_pkg.debug ('PN_VAR_RENT_PKG.FIND_IF_INV_EXP (-)');

EXCEPTION

  WHEN OTHERS THEN
    RETURN NULL;

END find_if_inv_exp;

-------------------------------------------------------------------------------
--  NAME         : rates_validation()
--  PURPOSE      : Vaidate Breakpoint Details Rates for FY,FLY,LY,CYP,CYNP
--  DESCRIPTION  :
--
--  1. FY and FYLY do not need to support a case where there is a rate
--     change in the FIRST12 months of the lease.
--  2. LY and FYLY do not need to support a case where there is a rate
--     change in the LAST 12 months of the lease.
--  3. The two Combined Year methods do not need to support a case where
--     there is a rate change in the first combined year.
--
--
--  SCOPE        : PUBLIC
--
--  ARGUMENTS    : p_var_rent_id : variable rent ID (mandatory)
--
--  RETURNS      : l_return_status
--  HISTORY      :
--
--  04-MAY-07    Pikhar  o Created.
--  23-MAY-07    Pikhar  o Revamped the entire procedure.
-------------------------------------------------------------------------------
FUNCTION  rates_validation (p_var_rent_id    IN NUMBER
                           ,p_agr_start_date IN DATE
                           ,p_agr_end_date   IN DATE) RETURN VARCHAR2
IS

TYPE bkpt_rec is RECORD ( l_bkpt_det_id           NUMBER,
                          l_bkpt_start_date       DATE,
                          l_bkpt_end_date         DATE,
                          l_bkpt_vol_start        NUMBER,
                          l_bkpt_vol_end          NUMBER,
                          l_rate                  NUMBER);

TYPE bkpt_rec_type is TABLE OF bkpt_rec INDEX BY BINARY_INTEGER;

l_agr_start_date     DATE;
l_agr_end_date       DATE;
l_agreement_end_date DATE;
l_prd_start_date     DATE;
l_prd_end_date       DATE;
l_proration_rule     VARCHAR2(30);
l_counter            NUMBER;
l_count_record       NUMBER;
l_return_status      VARCHAR2(30)   := 'NO_ERROR';
l_bkpt_st_tab        bkpt_rec_type;
l_bkpt_end_tab       bkpt_rec_type;
l1_bkpt_start_volume NUMBER;
l1_bkpt_end_volume   NUMBER;
l2_bkpt_start_volume NUMBER;
l2_bkpt_end_volume   NUMBER;

/* Cursor to get VR details */

 CURSOR var_cur(p_vr_id IN NUMBER) IS
   SELECT commencement_date
         ,termination_date
         ,proration_rule
   FROM pn_var_rents_all
   WHERE var_rent_id = p_vr_id;

/* Cursor to get var periods */
CURSOR periods_vr_c(p_vr_id IN NUMBER) IS
   SELECT start_date
         ,end_date
   FROM   pn_var_periods_all
   WHERE  var_rent_id = p_vr_id
   ORDER BY start_date;

/* Cursor to select Breakpoints whose start date
   is in between given start dates */
CURSOR bkdt_st_dt_cur (p_vr_id IN NUMBER,
                       p_start_date IN DATE,
                       p_end_date IN DATE) IS
  SELECT bkdt_default_id,
         bkdt_start_date,
         bkdt_end_date,
         period_bkpt_vol_start,
         period_bkpt_vol_end,
         bkpt_rate
  FROM pn_var_bkdt_defaults_all
  WHERE var_rent_id = p_vr_id
  AND bkdt_start_date BETWEEN p_start_date AND p_end_date;

/* Cursor to select Breakpoints whose end date
   is in between given start dates */
CURSOR bkdt_end_dt_cur (p_vr_id IN NUMBER,
                        p_start_date IN DATE,
                        p_end_date IN DATE) IS
  SELECT bkdt_default_id,
         bkdt_start_date,
         bkdt_end_date,
         period_bkpt_vol_start,
         period_bkpt_vol_end,
         bkpt_rate
  FROM pn_var_bkdt_defaults_all
  WHERE var_rent_id = p_vr_id
  AND bkdt_end_date BETWEEN p_start_date AND p_end_date;

BEGIN

   pnp_debug_pkg.log('pn_var_rent_pkg.rates_validation (+)');

   FOR var_rec in var_cur(p_vr_id => p_var_rent_id) LOOP
     IF p_agr_start_date IS NOT NULL THEN
        l_agr_start_date := p_agr_start_date;
     ELSE
        l_agr_start_date := var_rec.commencement_date;
     END IF;

     IF p_agr_end_date IS NOT NULL THEN
        l_agr_end_date := p_agr_end_date;
     ELSE
        l_agr_end_date   := var_rec.termination_date;
     END IF;

     l_agreement_end_date := var_rec.termination_date;
     l_proration_rule     := var_rec.proration_rule;


   END LOOP;


   IF l_proration_rule IN ('FY') THEN

      l_prd_start_date := l_agr_start_date;
      l_prd_end_date := (add_months(l_prd_start_date,12) -1);
      l_bkpt_st_tab.DELETE;

      IF ((l_prd_start_date IS NOT NULL) AND (l_prd_end_date IS NOT NULL)) THEN

          OPEN bkdt_st_dt_cur(p_vr_id => p_var_rent_id,
                              p_start_date => l_prd_start_date,
                              p_end_date => l_prd_end_date);
          FETCH bkdt_st_dt_cur BULK COLLECT INTO l_bkpt_st_tab;
          CLOSE bkdt_st_dt_cur;

      END IF;

   ELSIF l_proration_rule IN ('LY') THEN

      l_prd_end_date := l_agr_end_date;
      l_prd_start_date := (add_months(l_prd_end_date,-12) +1);
      l_bkpt_end_tab.DELETE;


      IF ((l_prd_start_date IS NOT NULL) AND (l_prd_end_date IS NOT NULL)) THEN

          OPEN bkdt_end_dt_cur(p_vr_id => p_var_rent_id,
                               p_start_date => l_prd_start_date,
                               p_end_date => l_prd_end_date);
          FETCH bkdt_end_dt_cur BULK COLLECT INTO l_bkpt_end_tab;
          CLOSE bkdt_end_dt_cur;

      END IF;

   ELSIF l_proration_rule IN ('FLY') THEN

      l_prd_start_date := l_agr_start_date;
      l_prd_end_date := (add_months(l_prd_start_date,12) -1);
      l_bkpt_st_tab.DELETE;

      IF ((l_prd_start_date IS NOT NULL) AND (l_prd_end_date IS NOT NULL)) THEN

          OPEN bkdt_st_dt_cur(p_vr_id => p_var_rent_id,
                              p_start_date => l_prd_start_date,
                              p_end_date => l_prd_end_date);
          FETCH bkdt_st_dt_cur BULK COLLECT INTO l_bkpt_st_tab;
          CLOSE bkdt_st_dt_cur;

      END IF;

      l_prd_end_date := l_agr_end_date;
      l_prd_start_date := (add_months(l_prd_end_date,-12) +1);
      l_bkpt_end_tab.DELETE;

      IF ((l_prd_start_date IS NOT NULL) AND (l_prd_end_date IS NOT NULL)) THEN

          OPEN bkdt_end_dt_cur(p_vr_id => p_var_rent_id,
                               p_start_date => l_prd_start_date,
                               p_end_date => l_prd_end_date);
          FETCH bkdt_end_dt_cur BULK COLLECT INTO l_bkpt_end_tab;
          CLOSE bkdt_end_dt_cur;

      END IF;


   ELSIF l_proration_rule IN ('CYP','CYNP') THEN

      l_counter := 0;

      <<outer>>
      FOR period_rec in periods_vr_c(p_vr_id => p_var_rent_id) LOOP
         IF l_counter = 0 THEN
            l_prd_start_date := period_rec.start_date;  /*Start date of first period*/
            l_prd_end_date   := NULL;
            l_counter := 1;
         ELSE
            l_prd_end_date := period_rec.end_date; /* End date of second period*/
            EXIT outer;
         END IF;
      END LOOP;

      l_bkpt_st_tab.DELETE;

      IF ((l_prd_start_date IS NOT NULL) AND (l_prd_end_date IS NOT NULL)) THEN

          OPEN bkdt_st_dt_cur(p_vr_id => p_var_rent_id,
                              p_start_date => l_prd_start_date,
                              p_end_date => l_prd_end_date);
          FETCH bkdt_st_dt_cur BULK COLLECT INTO l_bkpt_st_tab;
          CLOSE bkdt_st_dt_cur;

      END IF;

   END IF;


   /* Loop through Breakpoints table and check if there are
      any records with invalid rates */
   IF ((l_proration_rule IN ('CYP','CYNP', 'FY' , 'FLY')) AND (l_bkpt_st_tab.count > 0)) THEN
     <<outer_st_1>>
     FOR rec IN l_bkpt_st_tab.FIRST..l_bkpt_st_tab.LAST LOOP

       l1_bkpt_start_volume := NVL(l_bkpt_st_tab(rec).l_bkpt_vol_start,0);
       l1_bkpt_end_volume   := l_bkpt_st_tab(rec).l_bkpt_vol_end;

      <<inner_1>>
      FOR j in l_bkpt_st_tab.FIRST .. l_bkpt_st_tab.LAST LOOP

          IF l_bkpt_st_tab(rec).l_bkpt_det_id  <> l_bkpt_st_tab(j).l_bkpt_det_id   THEN

             l2_bkpt_start_volume := NVL(l_bkpt_st_tab(j).l_bkpt_vol_start,0);
             l2_bkpt_end_volume   := l_bkpt_st_tab(j).l_bkpt_vol_end;

             IF l2_bkpt_end_volume IS NULL THEN

                IF l1_bkpt_end_volume IS NULL THEN

                   IF l_bkpt_st_tab(rec).l_rate <> l_bkpt_st_tab(j).l_rate THEN
                      l_return_status := 'ERROR';
                      EXIT outer_st_1;
                   END IF;

                ELSE

                   IF ((l2_bkpt_start_volume BETWEEN l1_bkpt_start_volume AND l1_bkpt_end_volume) AND
                       (l2_bkpt_start_volume <> l1_bkpt_end_volume) AND
                       (l_bkpt_st_tab(rec).l_rate <> l_bkpt_st_tab(j).l_rate)) THEN
                      l_return_status := 'ERROR';
                      EXIT outer_st_1;
                   END IF;

                END IF;

             ELSE

                IF l1_bkpt_end_volume IS NULL THEN

                   IF ((l1_bkpt_start_volume BETWEEN l2_bkpt_start_volume AND l2_bkpt_end_volume) AND
                        l1_bkpt_start_volume <> l2_bkpt_end_volume AND
                        (l_bkpt_st_tab(rec).l_rate <> l_bkpt_st_tab(j).l_rate)) THEN
                      l_return_status := 'ERROR';
                      EXIT outer_st_1;
                   END IF;

                ELSE

                   IF  ((l1_bkpt_start_volume < l2_bkpt_end_volume)  AND (l2_bkpt_start_volume < l1_bkpt_end_volume )) AND
                       ( (l_bkpt_st_tab(rec).l_rate <> l_bkpt_st_tab(j).l_rate) )   THEN
                      l_return_status := 'ERROR';
                      EXIT outer_st_1;
                   END IF;

                END IF;

             END IF;

           END IF;

        END LOOP; -- inner

     END LOOP; -- outer_st_1

   END IF;

   IF  ((l_proration_rule IN ('LY','FLY')) AND (l_bkpt_end_tab.count > 0) AND l_return_status <> 'ERROR' )THEN
     <<outer_et_1>>
     FOR rec IN l_bkpt_end_tab.FIRST..l_bkpt_end_tab.LAST LOOP

       l1_bkpt_start_volume := NVL(l_bkpt_end_tab(rec).l_bkpt_vol_start,0);
       l1_bkpt_end_volume   := l_bkpt_end_tab(rec).l_bkpt_vol_end;

      <<inner_2>>
      FOR j in l_bkpt_end_tab.FIRST .. l_bkpt_end_tab.LAST LOOP

          IF l_bkpt_end_tab(rec).l_bkpt_det_id  <> l_bkpt_end_tab(j).l_bkpt_det_id   THEN

             l2_bkpt_start_volume := NVL(l_bkpt_end_tab(j).l_bkpt_vol_start,0);
             l2_bkpt_end_volume   := l_bkpt_end_tab(j).l_bkpt_vol_end;

             IF l2_bkpt_end_volume IS NULL THEN

                IF l1_bkpt_end_volume IS NULL THEN

                   IF l_bkpt_end_tab(rec).l_rate <> l_bkpt_end_tab(j).l_rate THEN
                      l_return_status := 'ERROR';
                      EXIT outer_et_1;
                   END IF;

                ELSE

                   IF ((l2_bkpt_start_volume BETWEEN l1_bkpt_start_volume AND l1_bkpt_end_volume) AND
                       (l2_bkpt_start_volume <> l1_bkpt_end_volume) AND
                       (l_bkpt_end_tab(rec).l_rate <> l_bkpt_end_tab(j).l_rate)) THEN
                      l_return_status := 'ERROR';
                      EXIT outer_et_1;
                   END IF;

                END IF;

             ELSE

                IF l1_bkpt_end_volume IS NULL THEN

                   IF ((l1_bkpt_start_volume BETWEEN l2_bkpt_start_volume AND l2_bkpt_end_volume) AND
                        l1_bkpt_start_volume <> l2_bkpt_end_volume AND
                        (l_bkpt_end_tab(rec).l_rate <> l_bkpt_end_tab(j).l_rate)) THEN
                      l_return_status := 'ERROR';
                      EXIT outer_et_1;
                   END IF;

                ELSE

                   IF  ((l1_bkpt_start_volume < l2_bkpt_end_volume)  AND (l2_bkpt_start_volume < l1_bkpt_end_volume )) AND
                       ( (l_bkpt_end_tab(rec).l_rate <> l_bkpt_end_tab(j).l_rate) )   THEN
                      l_return_status := 'ERROR';
                      EXIT outer_et_1;
                   END IF;

                END IF;

             END IF;

           END IF;

        END LOOP; -- inner2

     END LOOP; -- outer_et_1
   END IF;

   RETURN l_return_status;

   pnp_debug_pkg.log('pn_var_rent_pkg.rates_validation (-)');

END rates_validation;


END PN_VAR_RENT_PKG;

/
