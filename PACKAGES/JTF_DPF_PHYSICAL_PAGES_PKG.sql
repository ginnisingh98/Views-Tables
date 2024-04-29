--------------------------------------------------------
--  DDL for Package JTF_DPF_PHYSICAL_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF_PHYSICAL_PAGES_PKG" AUTHID CURRENT_USER as
/* $Header: jtfdpfps.pls 120.2 2005/10/25 05:18:11 psanyal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_PHYSICAL_PAGE_ID in NUMBER,
  X_PHYSICAL_PAGE_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PHYSICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PHYSICAL_PAGE_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_PAGE_NAME IN VARCHAR2,
  X_APPLICATION_ID IN VARCHAR2,
  X_PAGE_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2
);

procedure LOAD_ROW (
  X_PAGE_NAME IN VARCHAR2,
  X_APPLICATION_ID IN VARCHAR2,
  X_PAGE_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2
);

-- insert a row for the JTF_DPF_PHY_ATTRIBS table
procedure insert_phy_attributes(
  X_PHYS_ID IN NUMBER,
  X_PAGE_ATTRIBUTE_NAME IN VARCHAR2,
  X_PAGE_ATTRIBUTE_VALUE IN VARCHAR2,
  X_OWNER IN VARCHAR2
);

-- update a row for the JTF_DPF_PHY_ATTRIBS table
procedure update_phy_attributes(
  X_PHYS_ID IN NUMBER,
  X_PAGE_ATTRIBUTE_NAME IN VARCHAR2,
  X_PAGE_ATTRIBUTE_VALUE IN VARCHAR2,
  X_OWNER IN VARCHAR2
);

-- Find the physical_page_id to a page which has the given
-- name and appid.    If more than one physical matches
-- those criteria, preference is given to:
--  (1) the oldest which has last_updated_by = x_last_updated_by, if any, else
--  (2) the oldest
-- where 'oldest' means that it has the earliest last_update_date
--
-- If no pages have that name and appid, returns null

function find_oldest_prefer_owned_by(
  x_page_name in varchar2,
  x_application_id in varchar2,
  x_last_updated_by number) return number;

end JTF_DPF_PHYSICAL_PAGES_PKG;

 

/
