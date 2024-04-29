--------------------------------------------------------
--  DDL for Package Body PER_CALENDAR_ENTRIES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CALENDAR_ENTRIES_LOAD_PKG" as
/* $Header: peentlct.pkb 120.0 2005/05/31 08:08 appldev noship $ */

procedure KEY_TO_IDS (
  X_IDENTIFIER_KEY           in VARCHAR2,
  X_FLEX_VALUE_SET_NAME      in VARCHAR2,
  X_HIERARCHY_NAME           in VARCHAR2,
  X_BUS_GRP_NAME             in VARCHAR2,
  X_ORG_HIER_NAME            in VARCHAR2,
  X_ORG_HIER_VERSION         in NUMBER,
  X_CALENDAR_ENTRY_ID 	     out nocopy NUMBER,
  X_FLEX_VALUE_SET_ID        out nocopy NUMBER,
  X_HIERARCHY_ID 	     out nocopy NUMBER,
  X_BUS_GRP_ID   	     out nocopy NUMBER,
  X_ORG_STRUCT_ID            out nocopy NUMBER,
  X_ORG_STRUCT_VER_ID        out nocopy NUMBER) is

  cursor CSR_HIERARCHY (
    X_HIERARCHY_NAME in VARCHAR2
  ) is
    select PGH.HIERARCHY_ID
    from  PER_GEN_HIERARCHY PGH
    where PGH.NAME = X_HIERARCHY_NAME;

  cursor CSR_FLEX_VALUE_SET (
    X_FLEX_VALUE_SET_NAME in VARCHAR2
  ) is
    select FVS.FLEX_VALUE_SET_ID
    from FND_FLEX_VALUE_SETS FVS
    where FVS.FLEX_VALUE_SET_NAME = X_FLEX_VALUE_SET_NAME;

  cursor CSR_CALENDAR_ENTRY (
    X_IDENTIFIER_KEY in VARCHAR2
  ) is
    select ENT.CALENDAR_ENTRY_ID
    from PER_CALENDAR_ENTRIES ENT
    where ENT.IDENTIFIER_KEY = X_IDENTIFIER_KEY;

  cursor CSR_SEQUENCE is
    select PER_CALENDAR_ENTRIES_S.nextval
    from   dual;

  cursor CSR_BUS_GRP (
    X_BUS_GRP_NAME in VARCHAR2
  )is
    select HOU.BUSINESS_GROUP_ID
    from HR_ALL_ORGANIZATION_UNITS HOU
    where HOU.NAME = X_BUS_GRP_NAME
    and HOU.ORGANIZATION_ID = HOU.BUSINESS_GROUP_ID;

  cursor CSR_ORG_STRUCT (
    X_ORG_HIER_NAME in VARCHAR2
  ) is
    select POS.ORGANIZATION_STRUCTURE_ID
    from PER_ORGANIZATION_STRUCTURES POS
    where POS.NAME = X_ORG_HIER_NAME;

  cursor CSR_ORG_STRUCT_VER (
    X_ORG_HIER_NAME in VARCHAR2,
    X_ORG_HIER_VERSION in NUMBER
  ) is
    select POSV.ORG_STRUCTURE_VERSION_ID
    from PER_ORGANIZATION_STRUCTURES POS,
         PER_ORG_STRUCTURE_VERSIONS POSV
    where POS.NAME = X_ORG_HIER_NAME
    and POS.ORGANIZATION_STRUCTURE_ID = POSV.ORGANIZATION_STRUCTURE_ID
    and POSV.VERSION_NUMBER = X_ORG_HIER_VERSION;

begin

  open CSR_HIERARCHY (
    X_HIERARCHY_NAME
  );
  fetch CSR_HIERARCHY into X_HIERARCHY_ID;
  close CSR_HIERARCHY;

  open CSR_FLEX_VALUE_SET (
    X_FLEX_VALUE_SET_NAME
  );
  fetch CSR_FLEX_VALUE_SET into X_FLEX_VALUE_SET_ID;
  close CSR_FLEX_VALUE_SET;

  open CSR_CALENDAR_ENTRY (
    X_IDENTIFIER_KEY
  );
  fetch CSR_CALENDAR_ENTRY into X_CALENDAR_ENTRY_ID;
  if (CSR_CALENDAR_ENTRY%notfound) then
    close CSR_CALENDAR_ENTRY;
    open CSR_SEQUENCE;
    fetch CSR_SEQUENCE into X_CALENDAR_ENTRY_ID;
    close CSR_SEQUENCE;
  else
    close CSR_CALENDAR_ENTRY;
  end if;

  open CSR_BUS_GRP (
    X_BUS_GRP_NAME
  );
  fetch CSR_BUS_GRP into X_BUS_GRP_ID;
  close CSR_BUS_GRP;

  open CSR_ORG_STRUCT (
    X_ORG_HIER_NAME
  );
  fetch CSR_ORG_STRUCT into X_ORG_STRUCT_ID;
  close CSR_ORG_STRUCT;

  open CSR_ORG_STRUCT_VER (
    X_ORG_HIER_NAME,
    X_ORG_HIER_VERSION
  );
  fetch CSR_ORG_STRUCT_VER into X_ORG_STRUCT_VER_ID;
  close CSR_ORG_STRUCT_VER;

end KEY_TO_IDS;


procedure INSERT_ROW (
  X_CALENDAR_ENTRY_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_START_HOUR in VARCHAR2,
  X_START_MIN in VARCHAR2,
  X_END_HOUR in VARCHAR2,
  X_END_MIN in VARCHAR2,
  X_HIERARCHY_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_ORG_STRUCT_ID in NUMBER,
  X_ORG_STRUCT_VER_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_BUS_GRP_ID in NUMBER,
  X_IDENTIFIER_KEY in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
) is
  cursor C is select ROWID from PER_CALENDAR_ENTRIES
    where CALENDAR_ENTRY_ID = X_CALENDAR_ENTRY_ID
    ;
  csr_row C%rowtype;
begin
  insert into PER_CALENDAR_ENTRIES (
    CALENDAR_ENTRY_ID,
    NAME,
    TYPE,
    START_DATE,
    END_DATE,
    START_HOUR,
    START_MIN,
    END_HOUR,
    END_MIN,
    HIERARCHY_ID,
    VALUE_SET_ID,
    ORGANIZATION_STRUCTURE_ID,
    ORG_STRUCTURE_VERSION_ID,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    BUSINESS_GROUP_ID,
    IDENTIFIER_KEY,
    LEGISLATION_CODE
  ) values (
    X_CALENDAR_ENTRY_ID,
    X_NAME,
    X_TYPE,
    X_START_DATE,
    X_END_DATE,
    X_START_HOUR,
    X_START_MIN,
    X_END_HOUR,
    X_END_MIN,
    X_HIERARCHY_ID,
    X_VALUE_SET_ID,
    X_ORG_STRUCT_ID,
    X_ORG_STRUCT_VER_ID,
    X_DESCRIPTION,
    1,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_BUS_GRP_ID,
    X_IDENTIFIER_KEY,
    X_LEGISLATION_CODE
  );

  open c;
  fetch c into csr_row;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure LOAD_ROW (
  X_IDENTIFIER_KEY                      in VARCHAR2,
  X_LEGISLATION_CODE                    in VARCHAR2,
  X_BUS_GRP_NAME                        in VARCHAR2,
  X_NAME                                in VARCHAR2,
  X_START_DATE                          in VARCHAR2,
  X_END_DATE                            in VARCHAR2,
  X_TYPE                                in VARCHAR2,
  X_START_HOUR                          in VARCHAR2,
  X_START_MIN                           in VARCHAR2,
  X_END_HOUR                            in VARCHAR2,
  X_END_MIN                             in VARCHAR2,
  X_HIERARCHY_NAME                      in VARCHAR2,
  X_FLEX_VALUE_SET_NAME                 in VARCHAR2,
  X_ORG_HIER_NAME                       in VARCHAR2,
  X_ORG_HIER_VERSION                    in NUMBER,
  X_DESCRIPTION                         in VARCHAR2,
  X_OWNER                               in VARCHAR2,
  X_LAST_UPDATE_DATE                    in VARCHAR2)

is

  X_ROWID ROWID;
  user_id 		number := 0;
  X_CALENDAR_ENTRY_ID 	NUMBER;
  X_VALUE_SET_ID	NUMBER;
  X_HIERARCHY_ID	NUMBER;
  X_BUS_GRP_ID		NUMBER;
  X_ORG_STRUCT_ID	NUMBER;
  X_ORG_STRUCT_VER_ID	NUMBER;

begin

 -- translate keys to IDs
 -- (if inserting, CALENDAR_ENTRY_ID is obtained from sequence
 -- else from table)
 KEY_TO_IDS ( X_IDENTIFIER_KEY
             ,X_FLEX_VALUE_SET_NAME
             ,X_HIERARCHY_NAME
             ,X_BUS_GRP_NAME
             ,X_ORG_HIER_NAME
             ,X_ORG_HIER_VERSION
             ,X_CALENDAR_ENTRY_ID
             ,X_VALUE_SET_ID
             ,X_HIERARCHY_ID
             ,X_BUS_GRP_ID
             ,X_ORG_STRUCT_ID
             ,X_ORG_STRUCT_VER_ID);

  if (X_OWNER = 'SEED') then
    user_id := 1;
  else
    user_id := 0;
  end if;

   PER_CALENDAR_ENTRIES_LOAD_PKG.UPDATE_ROW (
     X_CALENDAR_ENTRY_ID         => X_CALENDAR_ENTRY_ID
    ,X_NAME 		         => X_NAME
    ,X_TYPE                      => X_TYPE
    ,X_START_DATE                => to_date(X_START_DATE,'DD/MM/YYYY')
    ,X_END_DATE                  => to_date(X_END_DATE,'DD/MM/YYYY')
    ,X_START_HOUR                => X_START_HOUR
    ,X_START_MIN                 => X_START_MIN
    ,X_END_HOUR                  => X_END_HOUR
    ,X_END_MIN                   => X_END_MIN
    ,X_VALUE_SET_ID              => X_VALUE_SET_ID
    ,X_HIERARCHY_ID              => X_HIERARCHY_ID
    ,X_ORG_STRUCT_ID             => X_ORG_STRUCT_ID
    ,X_ORG_STRUCT_VER_ID         => X_ORG_STRUCT_VER_ID
    ,X_DESCRIPTION               => X_DESCRIPTION
    ,X_LAST_UPDATE_DATE 	 => sysdate
    ,X_LAST_UPDATED_BY 	  	 => user_id
    ,X_LAST_UPDATE_LOGIN 	 => user_id);  -- note: ID Key, and LEG Code are not updateable

 exception
   when NO_DATA_FOUND then
     -- insert a row with NULL business group (meaningless)
     -- as data is created at Legislation level.
     -- (UI restricts on BG, or Leg Code).
    PER_CALENDAR_ENTRIES_LOAD_PKG.INSERT_ROW (
     X_CALENDAR_ENTRY_ID         => X_CALENDAR_ENTRY_ID
    ,X_NAME                      => X_NAME
    ,X_TYPE                      => X_TYPE
    ,X_START_DATE                => to_date(X_START_DATE,'DD/MM/YYYY')
    ,X_END_DATE                  => to_date(X_END_DATE,'DD/MM/YYYY')
    ,X_START_HOUR                => X_START_HOUR
    ,X_START_MIN                 => X_START_MIN
    ,X_END_HOUR                  => X_END_HOUR
    ,X_END_MIN                   => X_END_MIN
    ,X_VALUE_SET_ID              => X_VALUE_SET_ID
    ,X_HIERARCHY_ID              => X_HIERARCHY_ID
    ,X_ORG_STRUCT_ID             => X_ORG_STRUCT_ID
    ,X_ORG_STRUCT_VER_ID         => X_ORG_STRUCT_VER_ID
    ,X_DESCRIPTION               => X_DESCRIPTION
    ,X_LAST_UPDATE_DATE          => sysdate
    ,X_LAST_UPDATED_BY           => user_id
    ,X_LAST_UPDATE_LOGIN         => 0
    ,X_CREATION_DATE 		 => SYSDATE
    ,X_CREATED_BY   		 => user_id
    ,X_BUS_GRP_ID                => X_BUS_GRP_ID
    ,X_IDENTIFIER_KEY            => X_IDENTIFIER_KEY
    ,X_LEGISLATION_CODE          => X_LEGISLATION_CODE);

end LOAD_ROW;

procedure UPDATE_ROW (
  X_CALENDAR_ENTRY_ID                   in NUMBER,
  X_NAME                                in VARCHAR2,
  X_TYPE                                in VARCHAR2,
  X_START_DATE                          in DATE,
  X_END_DATE                            in DATE,
  X_START_HOUR                          in VARCHAR2,
  X_START_MIN                           in VARCHAR2,
  X_END_HOUR                            in VARCHAR2,
  X_END_MIN                             in VARCHAR2,
  X_HIERARCHY_ID                        in NUMBER,
  X_VALUE_SET_ID                        in NUMBER,
  X_ORG_STRUCT_ID                       in NUMBER,
  X_ORG_STRUCT_VER_ID                   in NUMBER,
  X_DESCRIPTION                         in VARCHAR2,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER) is
begin
  update PER_CALENDAR_ENTRIES set
    NAME = X_NAME,
    TYPE = X_TYPE,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    START_HOUR = X_START_HOUR,
    START_MIN = X_START_MIN,
    END_HOUR = X_END_HOUR,
    END_MIN = X_END_MIN,
    HIERARCHY_ID = HIERARCHY_ID,
    VALUE_SET_ID = X_VALUE_SET_ID,
    ORGANIZATION_STRUCTURE_ID = X_ORG_STRUCT_ID,
    ORG_STRUCTURE_VERSION_ID = X_ORG_STRUCT_VER_ID,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CALENDAR_ENTRY_ID = X_CALENDAR_ENTRY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

end PER_CALENDAR_ENTRIES_LOAD_PKG;

/
