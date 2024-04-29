--------------------------------------------------------
--  DDL for Package BNE_INTEGRATOR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_INTEGRATOR_UTILS" AUTHID CURRENT_USER AS
/* $Header: bneintgs.pls 120.8.12010000.2 2009/06/22 12:05:42 dhvenkat ship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      BNE_INTEGRATOR_UTILS                                        --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  22-APR-2002  JRICHARD  Created.                                           --
--  18-JUN-2002  KPEET     Updated to include CREATE_INTERFACE_FOR_API and    --
--                         renamed CREATE_INTERFACE to                        --
--                         CREATE_INTERFACE_FOR_TABLE and renamed             --
--                         INSERT_INTERFACE_COLUMN to UPSERT_INTERFACE_COLUMN.--
--  10-JUL-2002  KPEET     Added procedure CREATE_INTEGRATOR_NO_CONTENT to    --
--                         create an Integrator without a Content of "None".  --
--  01-OCT-2002  KPEET     Updated to reflect 8.3 schema changes.             --
--  29-OCT-2002  KPEET     Added IS_VALID_APPL_ID due to 8.3 schema changes.  --
--  07-NOV-2002  KPEET     Renamed CREATE_PARAMETER_LIST to be                --
--                         CREATE_API_PARAMETER_LIST.                         --
--  16-FEB-2005  DAGROVES  Bug 4187173 Added new columns to UPSERT_INTERFACE_COLUMN
--  26-JUL-2006  DAGROVES  Bug 4447161 Added P_USE_FND_METADATA flag to CREATE_INTERFACE_FOR_TABLE(),
--                         Added CREATE%LOV() methods.  Added DELETE%() methods.
--  14-AUG-2006  DAGROVES  Bug 5464481 - CREATE SCRIPTS FOR FLEXFIELD COLUMNS --
--  17-APR-2007  JRICHARD  Bug 5728544 - UNABLE TO UPLOAD DATA FOR 'WEB ADI - --
--                                            UPDATE INTERFACE COLUMN PROMPTS --
--------------------------------------------------------------------------------


FUNCTION IS_VALID_APPL_ID
                  (P_APPLICATION_ID IN NUMBER) RETURN BOOLEAN;

FUNCTION IS_VALID_OBJECT_CODE
                  (P_OBJECT_CODE IN VARCHAR2) RETURN BOOLEAN;

FUNCTION IS_VALID_OBJECT_CODE
                  (P_OBJECT_CODE IN VARCHAR2,
                   P_MAX_CODE_LENGTH IN NUMBER) RETURN BOOLEAN;


PROCEDURE LINK_LIST_TO_INTERFACE
                  (P_PARAM_LIST_APP_ID IN NUMBER,
                   P_PARAM_LIST_CODE   IN VARCHAR2,
                   P_INTERFACE_APP_ID  IN NUMBER,
                   P_INTERFACE_CODE    IN VARCHAR2);


PROCEDURE CREATE_API_PARAMETER_LIST
                  (P_PARAM_LIST_NAME    IN VARCHAR2,
                   P_API_PACKAGE_NAME   IN VARCHAR2,
                   P_API_PROCEDURE_NAME IN VARCHAR2,
                   P_API_TYPE           IN VARCHAR2,
                   P_API_RETURN_TYPE    IN VARCHAR2 DEFAULT NULL,
                   P_LANGUAGE           IN VARCHAR2,
                   P_SOURCE_LANG        IN VARCHAR2,
                   P_USER_ID            IN NUMBER,
                   P_OVERLOAD           IN NUMBER,
                   P_APPLICATION_ID     IN NUMBER,
                   P_OBJECT_CODE        IN VARCHAR2,
                   P_PARAM_LIST_CODE    OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_INTEGRATOR
                  (P_APPLICATION_ID       IN NUMBER,
                   P_OBJECT_CODE          IN VARCHAR2,
                   P_INTEGRATOR_USER_NAME IN VARCHAR2,
                   P_LANGUAGE             IN VARCHAR2,
                   P_SOURCE_LANGUAGE      IN VARCHAR2,
                   P_USER_ID              IN NUMBER,
                   P_INTEGRATOR_CODE      OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_INTEGRATOR_NO_CONTENT
                  (P_APPLICATION_ID       IN NUMBER,
                   P_OBJECT_CODE          IN VARCHAR2,
                   P_INTEGRATOR_USER_NAME IN VARCHAR2,
                   P_USER_ID              IN NUMBER,
                   P_LANGUAGE             IN VARCHAR2,
                   P_SOURCE_LANGUAGE      IN VARCHAR2,
                   P_INTEGRATOR_CODE      OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_INTERFACE_FOR_TABLE
                  (P_APPLICATION_ID        IN NUMBER,
                   P_OBJECT_CODE           IN VARCHAR2,
                   P_INTEGRATOR_CODE       IN VARCHAR2,
                   P_INTERFACE_TABLE_NAME  IN VARCHAR2,
                   P_INTERFACE_USER_NAME   IN VARCHAR2,
                   P_LANGUAGE              IN VARCHAR2,
                   P_SOURCE_LANG           IN VARCHAR2,
                   P_USER_ID               IN NUMBER,
                   P_INTERFACE_CODE        OUT NOCOPY VARCHAR2,
                   P_USE_FND_METADATA      IN BOOLEAN  DEFAULT TRUE,
                   P_INTERFACE_TABLE_OWNER IN VARCHAR2 DEFAULT 'APPS');


PROCEDURE CREATE_INTERFACE_FOR_API
                  (P_APPLICATION_ID      IN NUMBER,
                   P_OBJECT_CODE         IN VARCHAR2,
                   P_INTEGRATOR_CODE     IN VARCHAR2,
                   P_API_PACKAGE_NAME    IN VARCHAR2,
                   P_API_PROCEDURE_NAME  IN VARCHAR2,
                   P_INTERFACE_USER_NAME IN VARCHAR2,
                   P_PARAM_LIST_NAME     IN VARCHAR2,
                   P_API_TYPE            IN VARCHAR2,
                   P_API_RETURN_TYPE     IN VARCHAR2 DEFAULT NULL,
                   P_UPLOAD_TYPE         IN NUMBER,
                   P_LANGUAGE            IN VARCHAR2,
                   P_SOURCE_LANG         IN VARCHAR2,
                   P_USER_ID             IN NUMBER,
                   P_PARAM_LIST_CODE     OUT NOCOPY VARCHAR2,
                   P_INTERFACE_CODE      OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_INTERFACE_FOR_CONTENT
                  (P_APPLICATION_ID  IN NUMBER,
                   P_OBJECT_CODE     IN VARCHAR2,
                   P_CONTENT_CODE    IN VARCHAR2,
                   P_INTEGRATOR_CODE IN VARCHAR2,
                   P_LANGUAGE        IN VARCHAR2,
                   P_SOURCE_LANG     IN VARCHAR2,
                   P_USER_ID         IN NUMBER,
                   P_INTERFACE_CODE  OUT NOCOPY VARCHAR2);


PROCEDURE UPSERT_INTERFACE_COLUMN
                  (P_APPLICATION_ID IN NUMBER,
                   P_INTERFACE_CODE IN VARCHAR2,
                   P_SEQUENCE_NUM IN NUMBER,
                   P_INTERFACE_COL_TYPE IN NUMBER,
                   P_INTERFACE_COL_NAME IN VARCHAR2,
                   P_ENABLED_FLAG IN VARCHAR2,
                   P_REQUIRED_FLAG IN VARCHAR2,
                   P_DISPLAY_FLAG IN VARCHAR2,
                   P_FIELD_SIZE IN NUMBER DEFAULT NULL,
                   P_DEFAULT_TYPE IN VARCHAR2 DEFAULT NULL,
                   P_DEFAULT_VALUE IN VARCHAR2 DEFAULT NULL,
                   P_SEGMENT_NUMBER IN NUMBER DEFAULT NULL,
                   P_GROUP_NAME IN VARCHAR2 DEFAULT NULL,
                   P_OA_FLEX_CODE IN VARCHAR2 DEFAULT NULL,
                   P_OA_CONCAT_FLEX IN VARCHAR2 DEFAULT NULL,
                   P_READ_ONLY_FLAG IN VARCHAR2,
                   P_VAL_TYPE IN VARCHAR2 DEFAULT NULL,
                   P_VAL_ID_COL IN VARCHAR2 DEFAULT NULL,
                   P_VAL_MEAN_COL IN VARCHAR2 DEFAULT NULL,
                   P_VAL_DESC_COL IN VARCHAR2 DEFAULT NULL,
                   P_VAL_OBJ_NAME IN VARCHAR2 DEFAULT NULL,
                   P_VAL_ADDL_W_C IN VARCHAR2 DEFAULT NULL,
                   P_DATA_TYPE IN NUMBER DEFAULT NULL,
                   P_NOT_NULL_FLAG IN VARCHAR2,
                   P_VAL_COMPONENT_APP_ID IN NUMBER DEFAULT NULL,
                   P_VAL_COMPONENT_CODE IN VARCHAR2 DEFAULT NULL,
                   P_SUMMARY_FLAG IN VARCHAR2,
                   P_MAPPING_ENABLED_FLAG IN VARCHAR2,
                   P_PROMPT_LEFT IN VARCHAR2 DEFAULT NULL,
                   P_PROMPT_ABOVE IN VARCHAR2 DEFAULT NULL,
                   P_USER_HINT IN VARCHAR2 DEFAULT NULL,
                   P_USER_HELP_TEXT IN VARCHAR2 DEFAULT NULL,
                   P_LANGUAGE IN VARCHAR2,
                   P_SOURCE_LANG IN VARCHAR2,
                   P_OA_FLEX_NUM IN VARCHAR2 DEFAULT NULL,
                   P_OA_FLEX_APPLICATION_ID IN NUMBER DEFAULT NULL,
                   P_DISPLAY_ORDER IN NUMBER DEFAULT NULL,
                   P_UPLOAD_PARAM_LIST_ITEM_NUM IN NUMBER DEFAULT NULL,
                   P_EXPANDED_SQL_QUERY IN VARCHAR2 DEFAULT NULL,
                   P_LOV_TYPE IN VARCHAR2 DEFAULT NULL,
                   P_OFFLINE_LOV_ENABLED_FLAG IN VARCHAR2 DEFAULT NULL,
                   P_VARIABLE_DATA_TYPE_CLASS IN VARCHAR2 DEFAULT NULL,
                   P_USER_ID IN NUMBER);


PROCEDURE CREATE_INTERFACE_ALIAS_COLS
                  (P_APPLICATION_ID IN NUMBER,
                   P_INTERFACE_CODE IN VARCHAR2,
                   P_LANGUAGE       IN VARCHAR2,
                   P_SOURCE_LANG    IN VARCHAR2,
                   P_USER_ID        IN NUMBER,
                   P_VIEW_NAME      IN VARCHAR2,
                   P_CONTENT_CODE   IN VARCHAR2);


PROCEDURE CREATE_API_INTERFACE_AND_MAP
                  (P_APPLICATION_ID      IN NUMBER,
                   P_OBJECT_CODE         IN VARCHAR2,
                   P_INTEGRATOR_CODE     IN VARCHAR2,
                   P_API_PACKAGE_NAME    IN VARCHAR2,
                   P_API_PROCEDURE_NAME  IN VARCHAR2,
                   P_INTERFACE_USER_NAME IN VARCHAR2,
                   P_CONTENT_CODE        IN VARCHAR2,
                   P_VIEW_NAME           IN VARCHAR2,
                   P_PARAM_LIST_NAME     IN VARCHAR2,
                   P_API_TYPE            IN VARCHAR2,
                   P_API_RETURN_TYPE     IN VARCHAR2,
                   P_UPLOAD_TYPE         IN NUMBER,
                   P_LANGUAGE            IN VARCHAR2,
                   P_SOURCE_LANG         IN VARCHAR2,
                   P_USER_ID             IN NUMBER,
                   P_PARAM_LIST_CODE     OUT NOCOPY VARCHAR2,
                   P_INTERFACE_CODE      OUT NOCOPY VARCHAR2,
                   P_MAPPING_CODE        OUT NOCOPY VARCHAR2);

PROCEDURE CREATE_DEFAULT_LAYOUT
                  (P_APPLICATION_ID       IN NUMBER,
                   P_OBJECT_CODE          IN VARCHAR2,
                   P_INTEGRATOR_CODE      IN VARCHAR2,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_USER_ID              IN NUMBER,
                   P_FORCE                IN BOOLEAN,
                   P_ALL_COLUMNS          IN BOOLEAN,
                   P_LAYOUT_CODE          IN OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_TABLE_LOV                                        --
--                                                                            --
--  DESCRIPTION:      Create a Table LOV for a specific interface Column.     --
--  EXAMPLES:                                                                 --
--    BNE_INTEGRATOR_UTILS.CREATE_TABLE_LOV                                   --
--      (P_APPLICATION_ID       => 231,                                       --
--       P_INTERFACE_CODE       => 'MY_INTERFACE',                            --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_ID_COL               => 'LOOKUP_CODE', -- LOOKUP CODE UPLOADED     --
--       P_MEAN_COL             => 'MEANING',     -- Shown in sheet           --
--       P_DESC_COL             => NULL,                                      --
--       P_TABLE                => 'FND_LOOKUPS',                             --
--       P_ADDL_W_C             => 'lookup_type = ''YES_NO''',                --
--       P_WINDOW_CAPTION       => 'Yes/No with Meaning, selecting Meaning, Meaning sortable',--
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_SORT_ORDER     => 'ascending',                               --
--       P_USER_ID              => 2); -- SEED USER                           --
--                                                                            --
--    BNE_INTEGRATOR_UTILS.CREATE_TABLE_LOV                                   --
--      (P_APPLICATION_ID       => 231,                                       --
--       P_INTERFACE_CODE       => 'MY_INTERFACE',                            --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_ID_COL               => 'LOOKUP_CODE', -- LOOKUP CODE UPLOADED     --
--       P_MEAN_COL             => 'MEANING',     -- Shown in sheet           --
--       P_DESC_COL             => 'DESCRIPTION',                             --
--       P_TABLE                => 'FND_LOOKUPS',                             --
--       P_ADDL_W_C             => 'lookup_type = ''FND_CLIENT_CHARACTER_SETS''',
--       P_WINDOW_CAPTION       => 'Yes/No/All with Meaning and Description, selecting Meaning, Meaning sortable',--
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_SORT_ORDER     => 'yes,no', -- sortable by meaning, not description--
--       P_USER_ID              => 2); -- SEED USER                           --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_TABLE_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_ID_COL               IN VARCHAR2,
                   P_MEAN_COL             IN VARCHAR2,
                   P_DESC_COL             IN VARCHAR2,
                   P_TABLE                IN VARCHAR2,
                   P_ADDL_W_C             IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_BLOCK_SIZE     IN NUMBER,
                   P_TABLE_SORT_ORDER     IN VARCHAR2,
                   P_USER_ID              IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2 DEFAULT NULL,
                   P_TABLE_SELECT_COLUMNS IN VARCHAR2 DEFAULT NULL,
                   P_TABLE_COLUMN_ALIAS   IN VARCHAR2 DEFAULT NULL,
                   P_TABLE_HEADERS        IN VARCHAR2 DEFAULT NULL,
                   P_POPLIST_FLAG         IN VARCHAR2 DEFAULT 'N'
);

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_JAVA_LOV                                         --
--                                                                            --
--  DESCRIPTION:      Create a Table LOV for a specific interface Column.     --
--  EXAMPLES:                                                                 --
--    BNE_INTEGRATOR_UTILS.CREATE_JAVA_LOV                                    --
--      (P_APPLICATION_ID       => P_APPLICATION_ID,                          --
--       P_INTERFACE_CODE       => P_INTERFACE_CODE,                          --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_JAVA_CLASS           => 'oracle.apps.bne.lovtest.component.BneLOVTestSimpleJavaLOV01',--
--       P_WINDOW_CAPTION       => 'Java LOV selecting Code, Code sortable',  --
--       P_WINDOW_WIDTH         => 400,                                       --
--       P_WINDOW_HEIGHT        => 300,                                       --
--       P_TABLE_BLOCK_SIZE     => 10,                                        --
--       P_TABLE_COLUMNS        => 'LOOKUP_CODE',                             --
--       P_TABLE_SELECT_COLUMNS => NULL,                                      --
--       P_TABLE_COLUMN_ALIAS   => NULL,                                      --
--       P_TABLE_HEADERS        => 'Lookup Code',                             --
--       P_TABLE_SORT_ORDER     => 'yes',                                     --
--       P_USER_ID              => P_USER_ID);                                --
--                                                                            --
--    BNE_INTEGRATOR_UTILS.CREATE_JAVA_LOV                                    --
--      (P_APPLICATION_ID       => P_APPLICATION_ID,                          --
--       P_INTERFACE_CODE       => P_INTERFACE_CODE,                          --
--       P_INTERFACE_COL_NAME   => 'COL_NAME',                                --
--       P_JAVA_CLASS           => 'oracle.apps.bne.lovtest.component.BneLOVTestSimpleJavaLOV01',--
--       P_WINDOW_CAPTION       => 'Java LOV, Code, Meaning and Description selecting Code, Meaning and Description. Meaning and Description sortable, tablesize of 50',
--       P_WINDOW_WIDTH         => 500,                                       --
--       P_WINDOW_HEIGHT        => 500,                                       --
--       P_TABLE_BLOCK_SIZE     => 50,                                        --
--       P_TABLE_COLUMNS        => 'LOOKUP_CODE,MEANING,DESCRIPTION',         --
--       P_TABLE_SELECT_COLUMNS => 'STRING_COL06,STRING_COL08,STRING_COL07',  --
--       P_TABLE_COLUMN_ALIAS   => 'STRING_COL06,STRING_COL08,STRING_COL07',  --
--       P_TABLE_HEADERS        => 'Lookup Code, Meaning, Description',       --
--       P_TABLE_SORT_ORDER     => 'no, yes, yes',                            --
--       P_USER_ID              => P_USER_ID);                                --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_JAVA_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_JAVA_CLASS           IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_BLOCK_SIZE     IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2,
                   P_TABLE_SELECT_COLUMNS IN VARCHAR2,
                   P_TABLE_COLUMN_ALIAS   IN VARCHAR2,
                   P_TABLE_HEADERS        IN VARCHAR2,
                   P_TABLE_SORT_ORDER     IN VARCHAR2,
                   P_USER_ID              IN NUMBER);

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_CALENDAR_LOV                                     --
--                                                                            --
--  DESCRIPTION:      Create a Calendar LOV for a specific interface Column.  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_CALENDAR_LOV                            --
--          (P_APPLICATION_ID       => 231,                                   --
--           P_INTERFACE_CODE       => 'MY_INTERFACE',                        --
--           P_INTERFACE_COL_NAME   => 'COL_NAME',                            --
--           P_WINDOW_CAPTION       => 'Date Col LOV',                        --
--           P_WINDOW_WIDTH         => 230,                                   --
--           P_WINDOW_HEIGHT        => 220,                                   --
--           P_TABLE_COLUMNS        => NULL,                                  --
--           P_USER_ID              => 2);             -- SEED USER           --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CALENDAR_LOV
                  (P_APPLICATION_ID       IN NUMBER,
                   P_INTERFACE_CODE       IN VARCHAR2,
                   P_INTERFACE_COL_NAME   IN VARCHAR2,
                   P_WINDOW_CAPTION       IN VARCHAR2,
                   P_WINDOW_WIDTH         IN NUMBER,
                   P_WINDOW_HEIGHT        IN NUMBER,
                   P_TABLE_COLUMNS        IN VARCHAR2,
                   P_USER_ID              IN NUMBER);


--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_KFF                                              --
--                                                                            --
--  DESCRIPTION:      Create a Key Flexfield and generic LOV on an interface. --
--                    It is assumed that columns will already exist in the    --
--                    interface in the form P_FLEX_SEG_COL_NAME_PREFIX%, for  --
--                    example SEGMENT1,2,3 for P_FLEX_SEG_COL_NAME_PREFIX     --
--                    of SEGMENT.  An alias column will be created named      --
--                    P_GROUP_NAME for this KFF, and all segments and this    --
--                    alias column will be placed in a group P_GROUP_NAME.    --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneKFFValidator.java or                       --
--                              BneAccountingFlexValidator.java               --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.5 -       --
--                                  "Key Flexfield Validation/LOV Retrieval"  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_KFF                                     --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_FLEX_SEG_COL_NAME_PREFIX  => 'SEGMENT',              --
--                     P_GROUP_NAME                => 'ACCOUNT',              --
--                     P_REQUIRED_FLAG             => 'N',                    --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL#',                  --
--                     P_FLEX_NUM                  => 101,                    --
--                     P_VRULE                     => 'my vrule',             --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'Accounting Flexfield', --
--                     P_PROMPT_LEFT               => 'Accounting Flexfield', --
--                     P_USER_HINT                 => 'Enter Account',        --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_KFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_FLEX_SEG_COL_NAME_PREFIX  IN VARCHAR2,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_REQUIRED_FLAG             IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_FLEX_NUM                  IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER);

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_DFF                                              --
--                                                                            --
--  DESCRIPTION:      Create a Descriptive Flexfield and generic LOV on an    --
--                    interface.  It is assumed that columns will already     --
--                    exist in the interface in the form                      --
--                    P_FLEX_SEG_COL_NAME_PREFIX%, for example ATTRIBUTE1,2,3 --
--                    for P_FLEX_SEG_COL_NAME_PREFIX of ATTRIBUTE.            --
--                    An alias column will be created named P_GROUP_NAME for  --
--                    DFF, and all segments and this alias column will be     --
--                    placed in a group P_GROUP_NAME.                         --
--                    If a P_CONTEXT_COL_NAME is set, it must correspond to an--
--                    existing column in the interface and it will be used as --
--                    an external reference column.  It must correspond to the--
--                    Structure column as defined in the DFF Registered in    --
--                    Oracle Applications.                                    --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneDFFValidator.java)                         --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.7 -       --
--                          "Descriptive Flexfield Validation/LOV Retrieval"  --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_DFF                                     --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_FLEX_SEG_COL_NAME_PREFIX  => 'ATTRIBUTE',            --
--                     P_CONTEXT_COL_NAME          => 'CONTEXT',              --
--                     P_GROUP_NAME                => 'JOURNAL_LINES',        --
--                     P_REQUIRED_FLAG             => 'N',                    --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL_JE_LINES',          --
--                     P_VRULE                     => NULL,                   --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'Journal Lines',        --
--                     P_PROMPT_LEFT               => 'Journal Lines',        --
--                     P_USER_HINT                 => 'Enter Line',           --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_DFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_FLEX_SEG_COL_NAME_PREFIX  IN VARCHAR2,
                   P_CONTEXT_COL_NAME          IN VARCHAR2,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_REQUIRED_FLAG             IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER);

--------------------------------------------------------------------------------
--  PROCEDURE:        CREATE_CCID_KFF                                         --
--                                                                            --
--  DESCRIPTION:      Create a Key Flexfield and generic LOV on an interface. --
--                    It is assumed that a code combination column will       --
--                    already exist in the interface and be named             --
--                    P_INTERFACE_COL_NAME.                                   --
--                    Alias columns will be created in the interface named    --
--                    P_INTERFACE_COL_NAME||'_SEGMENT1' to                    --
--                    P_INTERFACE_COL_NAME||'_SEGMENT'||P_NUM_FLEX_SEGS.      --
--                    The following parameters are only used in the LOV, for  --
--                    upload validation, you need to develop a custom         --
--                    validator to perform validation to your business rules. --
--                    (Refer to BneKFFValidator.java or                       --
--                              BneAccountingFlexValidator.java               --
--                     P_VRULE                                                --
--                     P_EFFECTIVE_DATE_COL                                   --
--                    Reference: Web ADI Developers guide section 4.5 -       --
--                                  "Key Flexfield Validation/LOV Retrieval"  --
--                                                                            --
--  EXAMPLE:                                                                  --
--        BNE_INTEGRATOR_UTILS.CREATE_CCID_KFF                                --
--                    (P_APPLICATION_ID            => P_APPLICATION_ID,       --
--                     P_INTERFACE_CODE            => P_INTERFACE_CODE,       --
--                     P_INTERFACE_COL_NAME        => 'KEYFLEX1_CCID',        --
--                     P_NUM_FLEX_SEGS             => 10,                     --
--                     P_GROUP_NAME                => 'CCID_ACCOUNT1',        --
--                     P_FLEX_APPLICATION_ID       => 101,                    --
--                     P_FLEX_CODE                 => 'GL#',                  --
--                     P_FLEX_NUM                  => '50214',                --
--                     P_VRULE                     => NULL,                   --
--                     P_EFFECTIVE_DATE_COL        => 'DATE_COL01',           --
--                     P_PROMPT_ABOVE              => 'ADB Accounting Flexfield',--
--                     P_PROMPT_LEFT               => 'ADB Accounting Flexfield',--
--                     P_USER_HINT                 => 'Enter Account',        --
--                     P_USER_ID                   => P_USER_ID);             --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-AUG-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE CREATE_CCID_KFF
                  (P_APPLICATION_ID            IN NUMBER,
                   P_INTERFACE_CODE            IN VARCHAR2,
                   P_INTERFACE_COL_NAME        IN VARCHAR2,
                   P_NUM_FLEX_SEGS             IN NUMBER,
                   P_GROUP_NAME                IN VARCHAR2,
                   P_FLEX_APPLICATION_ID       IN NUMBER,
                   P_FLEX_CODE                 IN VARCHAR2,
                   P_FLEX_NUM                  IN VARCHAR2,
                   P_VRULE                     IN VARCHAR2,
                   P_EFFECTIVE_DATE_COL        IN VARCHAR2,
                   P_PROMPT_ABOVE              IN VARCHAR2,
                   P_PROMPT_LEFT               IN VARCHAR2,
                   P_USER_HINT                 IN VARCHAR2,
                   P_USER_ID                   IN NUMBER);


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_INTEGRATORS                                       --
--                                                                            --
--  DESCRIPTION: Delete all integrators for the given application id.         --
--               This will delete each integrator for the application id      --
--                 individually as per DELETE_INTEGRATOR().                   --
--               This will include all subsiduary structures:                 --
--                - Integrator and attached Parameter Lists                   --
--                - Interfaces         as per DELETE_ALL_INTERFACES()         --
--                - Contents           as per DELETE_ALL_CONTENTS()           --
--                - Mappings           as per DELETE_ALL_MAPPINGS()           --
--                - Layouts            as per DELETE_ALL_LAYOUTS()            --
--                - Duplicate Profiles as per DELETE_ALL_DUP_PROFILES()       --
--               The number of Integrators deleted is returned (0 or greater).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_INTEGRATORS
  (P_APPLICATION_ID       IN NUMBER)
RETURN NUMBER;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTEGRATOR                                            --
--                                                                            --
--  DESCRIPTION: Delete the given integrator.                                 --
--               This will include all subsiduary structures:                 --
--                - Integrator and attached Parameter Lists                   --
--                - Interfaces         as per DELETE_ALL_INTERFACES()         --
--                - Contents           as per DELETE_ALL_CONTENTS()           --
--                - Mappings           as per DELETE_ALL_MAPPINGS()           --
--                - Layouts            as per DELETE_ALL_LAYOUTS()            --
--                - Duplicate Profiles as per DELETE_ALL_DUP_PROFILES()       --
--                - Graphs/Graph Columns                                      --
--               The number of Integrators deleted is returned (0 or 1).      --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTEGRATOR
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_INTERFACES                                        --
--                                                                            --
--  DESCRIPTION: Delete all interfaces for the given integrator.              --
--               This will delete each interface for the integrator           --
--                 individually as per DELETE_INTERFACE().                    --
--               The number of interfaces deleted is returned (0 or greater). --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_INTERFACES
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTERFACE                                             --
--                                                                            --
--  DESCRIPTION: Delete the given interface.                                  --
--               This will include all subsiduary structures:                 --
--                - Interface                                                 --
--                - Interface Columns                                         --
--                - Interface Keys/Key columns                                --
--                - Interface Duplicate information                           --
--                - Queries    as per DELETE_QUERY_IF_UNREF()                 --
--                - Components as per DELETE_COMPONENT_IF_UNREF()             --
--               It will NOT delete layouts/components/mappings that reference--
--               the interface, use DELETE_INTEGRATOR for consistent deletion.--
--               of the entire entegrator structure.                          --
--               The number of interfaces deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTERFACE
  (P_APPLICATION_ID       IN NUMBER,
   P_INTERFACE_CODE       IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_INTERFACE_COL                                         --
--                                                                            --
--  DESCRIPTION: Delete the Interface Column.                                 --
--               This will include all subsiduary structures:                 --
--                - Component           as per DELETE_COMPONENT_IF_UNREF()    --
--                - Validation query    as per DELETE_QUERY_IF_UNREF()        --
--                - Expanded SQL query  as per DELETE_QUERY_IF_UNREF()        --
--               The number of Interface Columns deleted is returned (0 or 1).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_INTERFACE_COL
  (P_APPLICATION_ID       IN NUMBER,
   P_INTERFACE_CODE       IN VARCHAR2,
   P_SEQUENCE_NUM         IN NUMBER)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_DUP_PROFILES                                      --
--                                                                            --
--  DESCRIPTION: Delete all duplicate profiles for the given integrator.      --
--               This will delete each duplicate profile for the integrator   --
--                 individually as per DELETE_DUP_PROFILE().                  --
--               The number of profiles deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_DUP_PROFILES
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;


--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_DUP_PROFILE                                           --
--                                                                            --
--  DESCRIPTION: Delete the given duplicate profile.                          --
--               The number of duplicate profiles deleted is returned (0 or 1).--
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_DUP_PROFILE
  (P_APPLICATION_ID       IN NUMBER,
   P_DUP_PROFILE_CODE     IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_CONTENTS                                          --
--                                                                            --
--  DESCRIPTION: Delete all contents for the given integrator.                --
--               This will delete each content for the integrator             --
--                 individually as per DELETE_CONTENT().                      --
--               It will NOT delete any mappings that reference the content.  --
--               use DELETE_MAPPING or DELETE_INTEGRATOR for consistent       --
--               deletion.                                                    --
--               The number of contents deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_CONTENTS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_CONTENT                                               --
--                                                                            --
--  DESCRIPTION: Delete the given content.                                    --
--               This will include all subsiduary structures:                 --
--                - Contents                                                  --
--                - Content Columns                                           --
--                - Stored SQL definitions                                    --
--                - Text File definitions                                     --
--                - Queries    as per DELETE_QUERY_IF_UNREF()                 --
--               The number of content deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_CONTENT
  (P_APPLICATION_ID       IN NUMBER,
   P_CONTENT_CODE         IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_MAPPINGS                                          --
--                                                                            --
--  DESCRIPTION: Delete all mappings for the given integrator.                --
--               This will delete each mapping for the integrator             --
--                 individually as per DELETE_MAPPING().                      --
--               The number of mappings deleted is returned (0 or greater).   --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_MAPPINGS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_MAPPING                                               --
--                                                                            --
--  DESCRIPTION: Delete the given mapping.                                    --
--               This will include all subsiduary structures:                 --
--                - Mapping                                                   --
--                - Mapping Lines                                             --
--               The number of mappings deleted is returned (0 or 1).         --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_MAPPING
  (P_APPLICATION_ID       IN NUMBER,
   P_MAPPING_CODE         IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_ALL_LAYOUTS                                           --
--                                                                            --
--  DESCRIPTION: Delete all layouts for the given integrator.                 --
--               This will delete each layouts for the integrator             --
--                 individually as per DELETE_LAYOUT().                       --
--               The number of layouts deleted is returned (0 or greater).    --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_ALL_LAYOUTS
  (P_APPLICATION_ID       IN NUMBER,
   P_INTEGRATOR_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_LAYOUT                                                --
--                                                                            --
--  DESCRIPTION: Delete the given layout.                                     --
--               This will include all subsiduary structures:                 --
--                - Layout                                                    --
--                - Layout Blocks                                             --
--                - Layout Columns                                            --
--                - Layout LOBS                                               --
--                - Graphs/Graph Columns referencing the layout               --
--               The number of layouts deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_LAYOUT
  (P_APPLICATION_ID       IN NUMBER,
   P_LAYOUT_CODE          IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_COMPONENT                                             --
--                                                                            --
--  DESCRIPTION: Delete the given component.                                  --
--               This will include all subsiduary structures:                 --
--                - Component                                                 --
--                - Parameter List as per DELETE_PARAM_LIST_IF_UNREF()        --
--               The number of components deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_COMPONENT
  (P_APPLICATION_ID       IN NUMBER,
   P_COMPONENT_CODE       IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_COMPONENT_IF_UNREF                                    --
--                                                                            --
--  DESCRIPTION: Delete the given Component only if it is unreferenced        --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_COMPONENT() if unreferenced.    --
--               The number of components deleted is returned (0 or 1).       --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_COMPONENT_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_COMPONENT_CODE       IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_QUERY                                                 --
--                                                                            --
--  DESCRIPTION: Delete the given query.                                      --
--               This will include all subsiduary structures:                 --
--                - Query                                                     --
--                - Simple Query                                              --
--                - Raw Query Keys/Key columns                                --
--               The number of queries deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_QUERY
  (P_APPLICATION_ID       IN NUMBER,
   P_QUERY_CODE           IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_QUERY_IF_UNREF                                        --
--                                                                            --
--  DESCRIPTION: Delete the given Query only if it is unreferenced            --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_QUERY() if unreferenced.        --
--               The number of Queries deleted is returned (0 or 1).          --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_QUERY_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_QUERY_CODE           IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_PARAM_LIST                                            --
--                                                                            --
--  DESCRIPTION: Delete the given Parameter List.                             --
--               This will include all subsiduary structures:                 --
--                - List                                                      --
--                - List Items                                                --
--                - List Item Groups/Group Items                              --
--                - Definitions if otherwise unreferenced                     --
--                - Queries on definitions as per DELETE_QUERY_IF_UNREF()     --
--                - Attributes for list/items/groups/definitions if otherwise --
--                   unreferenced.                                            --
--               The number of lists deleted is returned (0 or 1).            --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_PARAM_LIST
  (P_APPLICATION_ID       IN NUMBER,
   P_PARAM_LIST_CODE      IN VARCHAR2)
RETURN NUMBER;

--------------------------------------------------------------------------------
--  FUNCTION:    DELETE_PARAM_LIST_IF_UNREF                                   --
--                                                                            --
--  DESCRIPTION: Delete the given Parameter List only if it is unreferenced   --
--               throughout the entire schema.  All FKs are checked.          --
--               Delete is done as per DELETE_PARAM_LIST() if unreferenced.   --
--               The number of lists deleted is returned (0 or 1).            --
--               No commits are done.                                         --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  20-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
FUNCTION DELETE_PARAM_LIST_IF_UNREF
  (P_APPLICATION_ID       IN NUMBER,
   P_PARAM_LIST_CODE      IN VARCHAR2)
RETURN NUMBER;


--------------------------------------------------------------------------------
--  FUNCTION:    UPDATE_INTERFACE_COLUMN_TEXT                                 --
--                                                                            --
--  DESCRIPTION: Procedure call developed for the Interface Column Prompts    --
--               Integrator.  Specifically requested by HRMS to allow their   --
--               customers a safe means for modifying the prompts of their    --
--               custom integrators.                                          --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  17-APR-2007  jrichard  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE UPDATE_INTERFACE_COLUMN_TEXT
                  (P_APPLICATION_ID IN NUMBER,
                   P_INTERFACE_CODE IN VARCHAR2,
                   P_SEQUENCE_NUM IN NUMBER,
                   P_LANGUAGE IN VARCHAR2,
                   P_SOURCE_LANG IN VARCHAR2,
                   P_PROMPT_LEFT IN VARCHAR2,
                   P_PROMPT_ABOVE IN VARCHAR2,
                   P_USER_HINT IN VARCHAR2,
                   P_USER_HELP_TEXT IN VARCHAR2 DEFAULT NULL,
                   P_USER_ID IN NUMBER);

--------------------------------------------------------------------------------
--  PROCEDURE:        ADD_LOV_PARAMETER_LIST                                  --
--                                                                            --
--  DESCRIPTION:      Create a parameter list for a LOV.                      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  11-JUL-2006  dagroves  Created.                                           --
--------------------------------------------------------------------------------
PROCEDURE ADD_LOV_PARAMETER_LIST
                  (P_APPLICATION_SHORT_NAME IN VARCHAR2,
                   P_PARAM_LIST_CODE        IN VARCHAR2,
                   P_PARAM_LIST_NAME        IN VARCHAR2,
                   P_WINDOW_CAPTION         IN VARCHAR2,
                   P_WINDOW_WIDTH           IN NUMBER,
                   P_WINDOW_HEIGHT          IN NUMBER,
                   P_TABLE_BLOCK_SIZE       IN NUMBER,
                   P_TABLE_COLUMNS          IN VARCHAR2,
                   P_TABLE_SELECT_COLUMNS   IN VARCHAR2,
                   P_TABLE_COLUMN_ALIAS     IN VARCHAR2,
                   P_TABLE_HEADERS          IN VARCHAR2,
                   P_TABLE_SORT_ORDER       IN VARCHAR2,
                   P_USER_NAME              IN VARCHAR2);

END BNE_INTEGRATOR_UTILS;

/
