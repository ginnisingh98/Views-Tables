--------------------------------------------------------
--  DDL for Package FND_PROFILE_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROFILE_HIERARCHY_PKG" AUTHID CURRENT_USER as
/* $Header: AFPOMPHS.pls 120.1 2005/07/02 04:13:13 appldev noship $ */

/*
*  X_MODE values for carry_profile_values procedure
*/
SUBTYPE SWITCH_MODE is INTEGER;

UPDATE_ONLY   CONSTANT INTEGER := 1;
INSERT_ONLY   CONSTANT INTEGER := 2;
INSERT_UPDATE CONSTANT INTEGER := 3;


/*
** The procedure carries a profile value and other who attributes when
** its hierarchy type is changed. The source and target hierarchy
** types should be from the set (SECURITY, SERVER, SERVRESP).
** Any other hierarchy switch is ignored. The following hierarchy
** switches are possible:
**
** 1. SECURITY TO SERVRESP
**    In this switch all the profile values at level 10003 are considered
**    for carring forward to level 10007.
** 2. SERVER TO SERVRESP
**    In this switch all the profile values at level 10005 are considered
**    for carring forward to level 10007.
** 3. SERVRESP TO SECURITY
**    In this switch all the profile values at level 10007 are considered
**    for carring forward to level 10003.
** 4. SERVRESP TO SERVER
**    In this switch all the profile values at level 10007 are considered
**    for carring forward to level 10005.
**
** what profile values are carried is controlled by the parameter X_MODE.
** profile option value rows can be either updatable rows or insertable rows.
**
** when a profile has rows existing at the target hierarchy level, they are called
** updatable rows. For example, when a profile hierarchy switch is from
** SECURITY to SERVRESP, all rows in FND_PROFILE_OPTION_VALUES for this  profile
** are considered updatable if there exist a valid LEVEL_VALUE2 value at level 10007.
**
** Insertable rows are all rows at source hierarchy level minus rows considered as
** updatable.
**
** 1. UPDATE_ONLY
**    In this mode profile option value and who columns of updatable rows are updated
**    from the similar rows at the source hierarchy level.
** 2. INSERT_ONLY
**    In this mode profile option value and who columns of insertable rows are inserted
**    at the target hierarchy level. Updatable rows are untouched.
** 3. INSERT_UPDATE
**    This mode is combination of both (1) and (2).
*/
procedure carry_profile_values(
         X_PROFILE_OPTION_NAME          in  VARCHAR2,
         X_APPLICATION_ID               in  NUMBER,
         X_PROFILE_OPTION_ID            in  NUMBER,
         X_TO_HIERARCHY_TYPE            in  VARCHAR2,
         X_LAST_UPDATE_DATE             in  DATE,
         X_LAST_UPDATED_BY              in  NUMBER,
         X_CREATION_DATE                in  DATE,
         X_CREATED_BY                   in  NUMBER,
         X_LAST_UPDATE_LOGIN            in  NUMBER,
         X_MODE                         in  NUMBER default INSERT_UPDATE
);

end FND_PROFILE_HIERARCHY_PKG;

 

/
