--------------------------------------------------------
--  DDL for Package Body PER_CAL_ENTRY_VALUES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAL_ENTRY_VALUES_LOAD_PKG" as
/* $Header: peenvlct.pkb 120.0 2005/05/31 08:10 appldev noship $ */


procedure KEY_TO_IDS (
  X_ENTRY_IDENTIFIER_KEY          in VARCHAR2,
  X_VALUE_IDENTIFIER_KEY          in VARCHAR2,
  X_HIERARCHY_NODE_NAME           in VARCHAR2,
  X_PARENT_VALUE_ID_KEY           in VARCHAR2,
  X_ORG_HIER_NAME                 in VARCHAR2,
  X_ORG_HIER_VERSION              in NUMBER,
  X_ORG_HIER_ELEMENT_PARENT       in VARCHAR2,
  X_ORG_HIER_ELEMENT_CHILD        in VARCHAR2,
  X_ORG_HIER_NODE_NAME            in VARCHAR2,
  X_CAL_ENTRY_VALUE_ID 	      out nocopy NUMBER,
  X_CALENDAR_ENTRY_ID         out nocopy NUMBER,
  X_HIERARCHY_NODE_ID 	      out nocopy NUMBER,
  X_PARENT_CAL_ENTRY_VALUE_ID out nocopy NUMBER,
  X_ORG_STRUCTURE_ELEMENT_ID  out nocopy NUMBER,
  X_ORGANIZATION_ID           out nocopy NUMBER) IS

  cursor CSR_CAL_ENTRY_VALUES (X_VALUE IN VARCHAR2) is
    select ENV.CAL_ENTRY_VALUE_ID
    from PER_CAL_ENTRY_VALUES ENV
    where ENV.IDENTIFIER_KEY = X_VALUE;

  cursor CSR_SEQUENCE is
    select PER_CAL_ENTRY_VALUES_S.nextval
    from   dual;

 cursor CSR_CALENDAR_ENTRY is
    select ENT.CALENDAR_ENTRY_ID
    from PER_CALENDAR_ENTRIES ENT
    where ENT.IDENTIFIER_KEY = X_ENTRY_IDENTIFIER_KEY;

 cursor CSR_HIERARCHY_NODE IS
    SELECT PGN.HIERARCHY_NODE_ID
    FROM PER_GEN_HIERARCHY_NODES PGN
    WHERE PGN.IDENTIFIER_KEY = X_HIERARCHY_NODE_NAME;

  cursor CSR_ORG_HIER_ELEMENT is
    select POSE.ORG_STRUCTURE_ELEMENT_ID
    from   PER_ORGANIZATION_STRUCTURES POS
          ,PER_ORG_STRUCTURE_VERSIONS  POSV
          ,PER_ORG_STRUCTURE_ELEMENTS  POSE
          ,HR_ALL_ORGANIZATION_UNITS   HOU_P
          ,HR_ALL_ORGANIZATION_UNITS   HOU_C
    where  POS.NAME = X_ORG_HIER_NAME
    and    POS.ORGANIZATION_STRUCTURE_ID = POSV.ORGANIZATION_STRUCTURE_ID
    and    POSV.VERSION_NUMBER = X_ORG_HIER_VERSION
    and    POSV.ORG_STRUCTURE_VERSION_ID = POSE.ORG_STRUCTURE_VERSION_ID
    and    POSE.ORGANIZATION_ID_PARENT = HOU_P.ORGANIZATION_ID
    and    HOU_P.NAME = X_ORG_HIER_ELEMENT_PARENT
    and    POSE.ORGANIZATION_ID_CHILD = HOU_C.ORGANIZATION_ID
    and    HOU_C.NAME = X_ORG_HIER_ELEMENT_CHILD;

  cursor CSR_ORG_HIER_NODE is
    select HOU.ORGANIZATION_ID
    from   HR_ALL_ORGANIZATION_UNITS HOU
    where  HOU.NAME = X_ORG_HIER_NODE_NAME;

begin

  -- decode the ENV identifier key, else insert new
  open CSR_CAL_ENTRY_VALUES(X_VALUE_IDENTIFIER_KEY);
  fetch CSR_CAL_ENTRY_VALUES into X_CAL_ENTRY_VALUE_ID;
  if (CSR_CAL_ENTRY_VALUES%notfound) then
    close CSR_CAL_ENTRY_VALUES;
    open CSR_SEQUENCE;
    fetch CSR_SEQUENCE into X_CAL_ENTRY_VALUE_ID;
    close CSR_SEQUENCE;
  else
    close CSR_CAL_ENTRY_VALUES;
  end if;

  open CSR_CALENDAR_ENTRY;
  fetch CSR_CALENDAR_ENTRY into X_CALENDAR_ENTRY_ID;
  close CSR_CALENDAR_ENTRY;

  -- decode of hierarchy node name
  IF X_HIERARCHY_NODE_NAME IS NOT NULL THEN
    open CSR_HIERARCHY_NODE;
    fetch CSR_HIERARCHY_NODE into X_HIERARCHY_NODE_ID;
    close CSR_HIERARCHY_NODE;
  END IF;

  IF X_PARENT_VALUE_ID_KEY IS NOT NULL THEN
    open CSR_CAL_ENTRY_VALUES (X_PARENT_VALUE_ID_KEY);
    fetch CSR_CAL_ENTRY_VALUES into X_PARENT_CAL_ENTRY_VALUE_ID;
    close CSR_CAL_ENTRY_VALUES;
  END IF;

  -- Decode the ORG hierarchy element  name
  IF X_ORG_HIER_NAME IS NOT NULL AND
     X_ORG_HIER_VERSION IS NOT NULL AND
     X_ORG_HIER_ELEMENT_PARENT IS NOT NULL AND
     X_ORG_HIER_ELEMENT_CHILD IS NOT NULL THEN
    open CSR_ORG_HIER_ELEMENT;
    fetch CSR_ORG_HIER_ELEMENT into X_ORG_STRUCTURE_ELEMENT_ID;
    close CSR_ORG_HIER_ELEMENT;
  END IF;

  -- Decode the ORG hierarchy node name
  IF X_ORG_HIER_NODE_NAME IS NOT NULL THEN
    open CSR_ORG_HIER_NODE;
    fetch CSR_ORG_HIER_NODE into X_ORGANIZATION_ID;
    close CSR_ORG_HIER_NODE;
  END IF;

exception
  when others then
  fnd_message.set_name('PAY', 'x_value:' || X_VALUE_IDENTIFIER_KEY);
    fnd_message.raise_error;


end KEY_TO_IDS;


procedure INSERT_ROW (
  X_CAL_ENTRY_VALUE_ID                  in NUMBER,
  X_CALENDAR_ENTRY_ID                   in NUMBER,
  X_HIERARCHY_NODE_ID                   in NUMBER,
  X_IDVALUE                             in VARCHAR2,
  X_ORG_STRUCTURE_ELEMENT_ID            in NUMBER,
  X_ORGANIZATION_ID                     in NUMBER,
  X_OVERRIDE_NAME                       in VARCHAR2,
  X_OVERRIDE_TYPE                       in VARCHAR2,
  X_PARENT_ENTRY_VALUE_ID               in NUMBER,
  X_USAGE_FLAG                          in VARCHAR2,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_CREATION_DATE                       in DATE,
  X_IDENTIFIER_KEY                      in VARCHAR2) is

  cursor C is select ROWID from PER_CAL_ENTRY_VALUES
    where CAL_ENTRY_VALUE_ID = X_CAL_ENTRY_VALUE_ID;
  csr_row C%rowtype;
begin
  insert into PER_CAL_ENTRY_VALUES (
    CAL_ENTRY_VALUE_ID,
    CALENDAR_ENTRY_ID,
    HIERARCHY_NODE_ID,
    IDVALUE,
    ORG_STRUCTURE_ELEMENT_ID,
    ORGANIZATION_ID,
    OVERRIDE_NAME,
    OVERRIDE_TYPE,
    PARENT_ENTRY_VALUE_ID,
    USAGE_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    IDENTIFIER_KEY
  ) values (
    X_CAL_ENTRY_VALUE_ID,
    X_CALENDAR_ENTRY_ID,
    X_HIERARCHY_NODE_ID,
    X_IDVALUE,
    X_ORG_STRUCTURE_ELEMENT_ID,
    X_ORGANIZATION_ID,
    X_OVERRIDE_NAME,
    X_OVERRIDE_TYPE,
    X_PARENT_ENTRY_VALUE_ID,
    X_USAGE_FLAG,
    1,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_IDENTIFIER_KEY
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
  X_VALUE_IDENTIFIER_KEY                in VARCHAR2,
  X_PARENT_VALUE_IDENTIFIER_KEY         in VARCHAR2,
  X_ENTRY_IDENTIFIER_KEY                in VARCHAR2,
  X_HIERARCHY_NODE_NAME                 in VARCHAR2,
  X_IDVALUE                             in VARCHAR2,
  X_ORG_HIER_NAME                       in VARCHAR2,
  X_ORG_HIER_VERSION                    in NUMBER,
  X_ORG_HIER_ELEMENT_PARENT             in VARCHAR2,
  X_ORG_HIER_ELEMENT_CHILD              in VARCHAR2,
  X_ORG_HIER_NODE_NAME                  in VARCHAR2,
  X_OVERRIDE_NAME                       in VARCHAR2,
  X_OVERRIDE_TYPE                       in VARCHAR2,
  X_USAGE_FLAG                          in VARCHAR2,
  X_OWNER                               in VARCHAR2,
  X_LAST_UPDATE_DATE                    in VARCHAR2) IS

  X_ROWID ROWID;
  user_id 	          	number := 0;
  X_CAL_ENTRY_VALUE_ID 	        NUMBER;
  X_PARENT_ENTRY_VALUE_ID       NUMBER;
  X_CALENDAR_ENTRY_ID 	        NUMBER;
  X_HIERARCHY_NODE_ID	        NUMBER;
  X_ORG_STRUCTURE_ELEMENT_ID	NUMBER;
  X_ORGANIZATION_ID	        NUMBER;

begin

 -- translate keys to IDs
 -- (if inserting, CAL_ENTRY_VALUE_ID is obtained
 -- from sequence else from table)
 KEY_TO_IDS ( X_ENTRY_IDENTIFIER_KEY
             ,X_VALUE_IDENTIFIER_KEY
             ,X_HIERARCHY_NODE_NAME
             ,X_PARENT_VALUE_IDENTIFIER_KEY
             ,X_ORG_HIER_NAME
             ,X_ORG_HIER_VERSION
             ,X_ORG_HIER_ELEMENT_PARENT
             ,X_ORG_HIER_ELEMENT_CHILD
             ,X_ORG_HIER_NODE_NAME
             ,X_CAL_ENTRY_VALUE_ID
             ,X_CALENDAR_ENTRY_ID
             ,X_HIERARCHY_NODE_ID
             ,X_PARENT_ENTRY_VALUE_ID
             ,X_ORG_STRUCTURE_ELEMENT_ID
             ,X_ORGANIZATION_ID);

  if (X_OWNER = 'SEED') then
    user_id := 1;
  else
    user_id := 0;
  end if;

   PER_CAL_ENTRY_VALUES_LOAD_PKG.UPDATE_ROW (
     X_CAL_ENTRY_VALUE_ID         => X_CAL_ENTRY_VALUE_ID
    ,X_HIERARCHY_NODE_ID 	  => X_HIERARCHY_NODE_ID
    ,X_IDVALUE                    => X_IDVALUE
    ,X_ORG_STRUCTURE_ELEMENT_ID   => X_ORG_STRUCTURE_ELEMENT_ID
    ,X_ORGANIZATION_ID            => X_ORGANIZATION_ID
    ,X_OVERRIDE_NAME              => X_OVERRIDE_NAME
    ,X_OVERRIDE_TYPE              => X_OVERRIDE_TYPE
    ,X_USAGE_FLAG                 => X_USAGE_FLAG
    ,X_LAST_UPDATE_DATE           => sysdate
    ,X_LAST_UPDATED_BY 	  	  => user_id
    ,X_LAST_UPDATE_LOGIN 	  => user_id);

 exception
   when NO_DATA_FOUND then
    PER_CAL_ENTRY_VALUES_LOAD_PKG.INSERT_ROW (
     X_CAL_ENTRY_VALUE_ID        => X_CAL_ENTRY_VALUE_ID
    ,X_CALENDAR_ENTRY_ID         => X_CALENDAR_ENTRY_ID
    ,X_HIERARCHY_NODE_ID         => X_HIERARCHY_NODE_ID
    ,X_IDVALUE                   => X_IDVALUE
    ,X_ORG_STRUCTURE_ELEMENT_ID  => X_ORG_STRUCTURE_ELEMENT_ID
    ,X_ORGANIZATION_ID           => X_ORGANIZATION_ID
    ,X_OVERRIDE_NAME             => X_OVERRIDE_NAME
    ,X_OVERRIDE_TYPE             => X_OVERRIDE_TYPE
    ,X_PARENT_ENTRY_VALUE_ID     => X_PARENT_ENTRY_VALUE_ID
    ,X_USAGE_FLAG                => X_USAGE_FLAG
    ,X_CREATED_BY                => user_id
    ,X_LAST_UPDATE_DATE          => sysdate
    ,X_LAST_UPDATED_BY           => user_id
    ,X_LAST_UPDATE_LOGIN         => 0
    ,X_CREATION_DATE 		 => SYSDATE
    ,X_IDENTIFIER_KEY            => X_VALUE_IDENTIFIER_KEY);

end LOAD_ROW;

procedure UPDATE_ROW (
   X_CAL_ENTRY_VALUE_ID                 in NUMBER,
   X_HIERARCHY_NODE_ID                  in NUMBER,
   X_IDVALUE                            in VARCHAR2,
   X_ORG_STRUCTURE_ELEMENT_ID           in NUMBER,
   X_ORGANIZATION_ID                    in NUMBER,
   X_OVERRIDE_NAME                      in VARCHAR2,
   X_OVERRIDE_TYPE                      in VARCHAR2,
   X_USAGE_FLAG                         in VARCHAR2,
   X_LAST_UPDATE_DATE                   in DATE,
   X_LAST_UPDATED_BY                    in NUMBER,
   X_LAST_UPDATE_LOGIN                  in NUMBER) IS

begin
  update PER_CAL_ENTRY_VALUES set
    HIERARCHY_NODE_ID = X_HIERARCHY_NODE_ID,
    IDVALUE = X_IDVALUE,
    ORG_STRUCTURE_ELEMENT_ID = X_ORG_STRUCTURE_ELEMENT_ID,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    OVERRIDE_NAME = X_OVERRIDE_NAME,
    OVERRIDE_TYPE = X_OVERRIDE_TYPE,
    USAGE_FLAG = X_USAGE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CAL_ENTRY_VALUE_ID = X_CAL_ENTRY_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

end PER_CAL_ENTRY_VALUES_LOAD_PKG;

/
