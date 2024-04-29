--------------------------------------------------------
--  DDL for Package CN_SYIN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SYIN_RULES_PKG" AUTHID CURRENT_USER AS
-- $Header: cnsyinfs.pls 120.6 2005/12/27 04:02:05 hanaraya ship $


--
-- Procedure Name
--   populate_fields
-- History
--   01/26/94         Tony Lower              Created
--   08-30-95         Amy Erickson            Updated
--
--
-- Procedure Name
--   populate_fields
-- History
--   01/26/94         Tony Lower              Created
--   08-30-95         Amy Erickson            Updated
--
PROCEDURE Populate_Fields (x_revenue_class_id   IN OUT NOCOPY number,
                           x_revenue_class_name IN OUT NOCOPY varchar2,
			   x_org_id IN NUMBER );


--
-- Procedure Name
--   unsync_ruleset
-- History
--   02-17-99   Renu Chintalapati    Created
--
PROCEDURE unsync_ruleset (x_ruleset_id number,
                          x_org_id number ) ;

--
-- Procedure Name
--   Insert_Row
-- History
--   08-08-95   Amy Erickson    Created
--   FEB-25-99  Harlen Chen     updated for MLS changes

PROCEDURE Insert_Row (x_rule_id             number,
                      x_name                varchar2,
                      x_ruleset_id          number,
                      x_revenue_class_id    number,
		      x_expense_ccid        NUMBER,
		      x_liability_ccid      NUMBER,
                      x_parent_rule_id      number,
                      x_sequence_number     number,
                      x_org_id number );

procedure insert_row_into_cn_rules_only
  (
  X_ROWID in out nocopy  VARCHAR2,
  X_RULE_ID in NUMBER := FND_API.G_MISS_NUM,
  X_RULESET_ID in NUMBER := FND_API.G_MISS_NUM,
  X_PACKAGE_ID in NUMBER := FND_API.G_MISS_NUM,
   X_REVENUE_CLASS_ID in NUMBER := FND_API.G_MISS_NUM,
   x_expense_ccid IN NUMBER := fnd_api.g_miss_num,
   x_liability_ccid IN NUMBER := fnd_api.g_miss_num,
  X_NAME in VARCHAR2 := FND_API.G_MISS_CHAR,
  X_CREATION_DATE in DATE := FND_API.G_MISS_DATE,
  X_CREATED_BY in NUMBER := FND_API.G_MISS_NUM,
  X_LAST_UPDATE_DATE in DATE := FND_API.G_MISS_DATE,
  X_LAST_UPDATED_BY in NUMBER := FND_API.G_MISS_NUM,
  X_LAST_UPDATE_LOGIN in NUMBER := FND_API.G_MISS_NUM,
  X_ORG_ID in NUMBER := FND_API.G_MISS_NUM);

--
-- Procedure Name
--   Update_Row
-- History
--   06-15-94   Tony Lower      Created
--   Feb-25-99  Harlen Chen     Updated: new tbl handler for MLS changes
--
--PROCEDURE Update_Row (x_rule_id             number,
--                      x_name                varchar2,
--                      x_revenue_class_id    number) ;
procedure UPDATE_ROW
  (
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_PACKAGE_ID in NUMBER,
   X_REVENUE_CLASS_ID in NUMBER,
   x_expense_ccid IN NUMBER,
   x_liability_ccid IN NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER,
  X_OBJECT_VERSION_NO IN OUT NOCOPY NUMBER
);
--
-- Procedure Name
--   Delete_Row
-- History
--   06-15-94   Tony Lower      Created
--
procedure DELETE_ROW (X_RULE_ID in NUMBER,
                      X_RULESET_ID in NUMBER,
                      X_ORG_ID in number );



--   30-JUL-98  Ram Kalyanasundaram	Created
--------------------------------------------------------------------------+
-- Procedure Name:	download				        --+
-- Purpose								--+
-- This procedure is used to download the required data to the inter-   --+
-- face table for export to a different data base                       --+
--------------------------------------------------------------------------+
PROCEDURE download(errbuf 	OUT NOCOPY VARCHAR2,
		   retcode	OUT NOCOPY NUMBER);

--   30-JUL-98  Ram Kalyanasundaram	Created
--------------------------------------------------------------------------+
-- Procedure Name:	upload				                --+
-- Purpose								--+
-- This procedure is used to upload the required data from the inter-   --+
-- face table to the appropriate tables in the database                 --+
--------------------------------------------------------------------------+
PROCEDURE upload(errbuf 	OUT NOCOPY VARCHAR2,
		 retcode	OUT NOCOPY NUMBER);



procedure ADD_LANGUAGE;
-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_rule_id IN NUMBER,
    x_ruleset_id IN NUMBER,
    x_package_id IN NUMBER,
    x_revenue_class_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id in number);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_rule_id IN NUMBER,
    x_ruleset_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id in number );

END cn_syin_rules_pkg;
 

/
