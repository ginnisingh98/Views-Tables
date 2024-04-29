--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_TEXT_UTIL" AS
/* $Header: EGOUIMTB.pls 120.8 2006/05/15 16:37:51 eletuchy noship $ */

G_PKG_NAME    CONSTANT  VARCHAR2(30)  :=  'EGO_ITEM_TEXT_UTIL';

-- -----------------------------------------------------------------------------
--          Private Globals
-- -----------------------------------------------------------------------------

g_Prod_Short_Name         CONSTANT VARCHAR2(30)  :=  'EGO';
g_Prod_Schema             VARCHAR2(30);
g_Index_Owner             VARCHAR2(30);
g_Index_Name              VARCHAR2(30)           :=  'EGO_ITEM_TEXT_TL_CTX1';
g_Indexing_Context        VARCHAR2(30)           :=  'SYNC_INDEX';

g_installed               BOOLEAN;
g_inst_status             VARCHAR2(1);
g_industry                VARCHAR2(1);

g_DB_Version_Num          NUMBER                 :=  NULL;
g_DB_Version_Str          VARCHAR2(30)           :=  NULL;
g_compatibility           VARCHAR2(30)           :=  NULL;

g_MSTK_Flex_Delimiter     VARCHAR2(1)            :=  NULL;

c_Ego_Appl_Id             CONSTANT NUMBER        :=  431;
c_Ego_DFF_Name            CONSTANT VARCHAR2(30)  :=  'EGO_ITEMMGMT_GROUP';

--Bug 4045988
  l_DB_Version_Str        VARCHAR2(30)           :=  NULL;
  l_DB_Numeric_Character  VARCHAR2(30)           :=  NULL;
--Bug 4045988

-- Global debug flag
g_Debug                   BOOLEAN                :=  FALSE;

   -- Document section tags

   Tag_itemcode               CONSTANT  VARCHAR2(30)  :=  'itemcode';
   Tag_begin_itemcode         CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_itemcode || '>';
   Tag_end_itemcode           CONSTANT  VARCHAR2(30)  :=  '</' || Tag_itemcode || '>';

   Tag_description            CONSTANT  VARCHAR2(30)  :=  'description';
   Tag_begin_description      CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_description || '>';
   Tag_end_description        CONSTANT  VARCHAR2(30)  :=  '</' || Tag_description || '>';

   Tag_shortdescr             CONSTANT  VARCHAR2(30)  :=  'shortdescr';
   Tag_begin_shortdescr       CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_shortdescr || '>';
   Tag_end_shortdescr         CONSTANT  VARCHAR2(30)  :=  '</' || Tag_shortdescr || '>';

   Tag_longdescr              CONSTANT  VARCHAR2(30)  :=  'longdescr';
   Tag_begin_longdescr        CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_longdescr || '>';
   Tag_end_longdescr          CONSTANT  VARCHAR2(30)  :=  '</' || Tag_longdescr || '>';

   Tag_internal               CONSTANT  VARCHAR2(30)  :=  'internalitem';
   Tag_begin_internal         CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_internal || '>';
   Tag_end_internal           CONSTANT  VARCHAR2(30)  :=  '</' || Tag_internal || '>';

   Tag_cataloggroupid_prefix  CONSTANT  VARCHAR2(30)  :=  'cataloggroup';
   l_Tag_catalog_group        VARCHAR2(30);
   l_Tag_begin_catalog_group  VARCHAR2(30);
   l_Tag_end_catalog_group    VARCHAR2(30);

   Tag_customer               CONSTANT  VARCHAR2(30)  :=  'customeritem';
   Tag_begin_customer         CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_customer || '>';
   Tag_end_customer           CONSTANT  VARCHAR2(30)  :=  '</' || Tag_customer || '>';

   Tag_reference              CONSTANT  VARCHAR2(30)  :=  'referenceitem';
   Tag_begin_reference        CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_reference || '>';
   Tag_end_reference          CONSTANT  VARCHAR2(30)  :=  '</' || Tag_reference || '>';

   Tag_userattribute          CONSTANT  VARCHAR2(30)  :=  'ua';
   Tag_begin_userattribute    CONSTANT  VARCHAR2(30)  :=  '<'  || Tag_userattribute || '>';
   Tag_end_userattribute      CONSTANT  VARCHAR2(30)  :=  '</' || Tag_userattribute || '>';
/*
   Tag_CategoryAssign         CONSTANT  VARCHAR2(30)  :=  'catassign';
   Tag_CategorySet            CONSTANT  VARCHAR2(30)  :=  'categoryset';
   Tag_Category               CONSTANT  VARCHAR2(30)  :=  'category';
*/

   -- Variable used to buffer text strings before writing into LOB.
   --
   g_Buffer                   VARCHAR2(32767);
   g_Buffer_Length            INTEGER;

/*
   TYPE Char_Tbl_Type IS TABLE OF VARCHAR2(32767)
                                  INDEX BY BINARY_INTEGER;

   g_Item_Ext_Text_Tbl    Char_Tbl_Type;
*/
-- -----------------------------------------------------------------------------
--          Debug
-- -----------------------------------------------------------------------------
PROCEDURE Debug
(
   p_item_id       IN    NUMBER
,  p_org_id        IN    NUMBER
,  p_msg_name      IN    VARCHAR2
,  p_error_text    IN    VARCHAR2
);

-- -----------------------------------------------------------------------------
--          Set_Context
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 )
IS
BEGIN
   g_Indexing_Context := p_context;
END Set_Context;

-- -----------------------------------------------------------------------------
--        Append_VARCHAR_to_LOB
-- -----------------------------------------------------------------------------

PROCEDURE Append_VARCHAR_to_LOB
(
   x_tlob      IN OUT NOCOPY  CLOB
,  p_string    IN             VARCHAR2
,  p_action    IN             VARCHAR2  DEFAULT  'APPEND'
)
IS
   start_writing    BOOLEAN  :=  TRUE;
   l_offset         INTEGER  :=  1;
   l_Max_Length     INTEGER  :=  32767;
   l_String_Length  INTEGER;
BEGIN

   IF ( p_action = 'BEGIN' ) THEN

      -- Empty the LOB, if this is the first chunk of text to append
      DBMS_LOB.Trim ( lob_loc => x_tlob, newlen => 0 );

      g_Buffer := p_string;
      g_Buffer_Length := -1;

   ELSIF ( p_action IN ('APPEND', 'END') ) THEN

      start_writing := ( g_Buffer_Length = -1 );
      IF ( start_writing ) THEN
         g_Buffer_Length := Length (g_Buffer);
      END IF;

      l_String_Length := Length (p_string);

      -- Write buffer to LOB if required

      IF ( g_Buffer_Length + l_String_Length >= l_Max_Length ) THEN
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;

         -- Reset buffer
         g_Buffer := p_string;
         g_Buffer_Length := Length (g_Buffer);
      ELSE
         g_Buffer := g_Buffer || p_string;
         g_Buffer_Length := g_Buffer_Length + l_String_Length;
      END IF;  -- Max_Length reached

      IF ( p_action = 'END' ) THEN
         start_writing := ( g_Buffer_Length = -1 );
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;
         -- Reset buffer
         g_Buffer := '';
         g_Buffer_Length := -1;
      END IF;

   END IF;  -- p_action

END Append_VARCHAR_to_LOB;

-- -----------------------------------------------------------------------------
--        Get_Item_Text
-- -----------------------------------------------------------------------------

PROCEDURE Get_Item_Text
(
   p_rowid          IN             ROWID
,  p_output_type    IN             VARCHAR2
,  x_tlob           IN OUT NOCOPY  CLOB
,  x_tchar          IN OUT NOCOPY  VARCHAR2
)
IS
   TYPE t_varchar_table IS TABLE OF VARCHAR2(150)
     INDEX BY BINARY_INTEGER;
   l_mfg_table              t_varchar_table;
   l_mpn_table              t_varchar_table;

   l_api_name               CONSTANT VARCHAR2(30)  :=  'Get_Item_Text';
   l_return_status          VARCHAR2(1);

   l_id_type                VARCHAR2(30);
   l_item_id                NUMBER;
   l_item_code              VARCHAR2(2000);
   l_item_segments          VARCHAR2(2000);
   l_org_id                 NUMBER;
   l_language               VARCHAR2(4);
   l_source_lang            VARCHAR2(4);
   l_item_catalog_group_id  NUMBER;

   --v_item_code              VARCHAR2(2000)  :=  NULL;
   --v_description            VARCHAR2(4000)  :=  NULL;
   --v_long_description       VARCHAR2(4000)  :=  NULL;

   l_description            VARCHAR2(240) := NULL;
   l_long_description       VARCHAR2(4000) := NULL;
   l_item_catalog_group     VARCHAR2(40) := NULL;

   l_text                   VARCHAR2(32767);
   l_amount                 BINARY_INTEGER;
   --l_buffer                 VARCHAR2(32767) :=  NULL;
   --pos1                     INTEGER;
   --pos2                     INTEGER;

   l_Tag_Id_type            VARCHAR2(30);
   --l_Tag_begin_Id_type      VARCHAR2(30);
   --l_Tag_end_Id_type        VARCHAR2(30);

BEGIN

   ------------------------------------------------------------------------
   -- Get item identifier record for a subsequent retrieval of inventory,
   -- customer, or cross_reference item (depending on the identifier type).
   ------------------------------------------------------------------------

   IF (p_output_type = 'VARCHAR2') THEN

     BEGIN

        SELECT
           eitl.id_type
        ,  eitl.item_id
        --,  eitl.item_code
        --,  eitl.org_id
        ,  eitl.language
        --,  eitl.source_lang
        --,  NVL(eitl.item_catalog_group_id, 0)
        --,  eitl.item_code ||' '|| TRANSLATE(eitl.item_code, g_MSTK_Flex_Delimiter, ' ')
        ,  eitl.item_code ||' '|| msitl.description ||' '|| msitl.long_description
        INTO
           l_id_type
        ,  l_item_id
        --,  l_item_code
        --,  l_org_id
        ,  l_language
        --,  l_source_lang
        --,  l_item_catalog_group_id
        --,  l_item_segments
        ,  l_text
        FROM
           ego_item_text_tl     eitl
        ,  mtl_system_items_tl  msitl
        WHERE
               eitl.rowid = p_rowid
           AND msitl.inventory_item_id = eitl.item_id
           AND msitl.organization_id   = eitl.org_id
           AND msitl.language          = eitl.language;

     EXCEPTION
        WHEN no_data_found THEN
           IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 0: ' || SQLERRM); END IF;
     END;

     IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
        l_text := TRANSLATE(l_text, '_*~^.$#@:|&', '----+++++++');
     END IF;

     x_tchar := l_text;

   ELSE

     -- This will be used to generate section tags;
     -- we return the text as a CLOB in case it gets large.
     -- (eg. an item with many associated MPN's)
     BEGIN

        -- Here we collect item_code, description, and long description
        -- for the row being processed; we also find its PK's and other
        -- information we will use to query other tables.
        SELECT
           eitl.item_id
        ,  eitl.org_id
        ,  eitl.item_code
        ,  msitl.description
        ,  msitl.long_description
        ,  eitl.item_catalog_group_id
        ,  eitl.language
        INTO
           l_item_id
        ,  l_org_id
        ,  l_item_code
        ,  l_description
        ,  l_long_description
        ,  l_item_catalog_group_id
        ,  l_language
        FROM
           ego_item_text_tl     eitl
        ,  mtl_system_items_tl  msitl
        WHERE
               eitl.rowid = p_rowid
           AND msitl.inventory_item_id = eitl.item_id
           AND msitl.organization_id   = eitl.org_id
           AND msitl.language          = eitl.language;

       -- Here we obtain the catalog category name.
       BEGIN
         SELECT micg.concatenated_segments item_catalog_group
           INTO l_item_catalog_group
           FROM mtl_item_catalog_groups_kfv micg
          WHERE micg.item_catalog_group_id = l_item_catalog_group_id;
       EXCEPTION
         WHEN no_data_found THEN
           l_item_catalog_group := NULL;
       END;

       -- Here we obtain a collection of manufacturer names
       -- and their corresponding part numbers, all of which are
       -- associated with the currently selected item
       SELECT mmpn.mfg_part_num
            , mm.manufacturer_name
         BULK COLLECT INTO
              l_mpn_table
            , l_mfg_table
         FROM MTL_MANUFACTURERS mm
            , MTL_MFG_PART_NUMBERS mmpn
        WHERE mm.manufacturer_id = mmpn.manufacturer_id
          AND mmpn.inventory_item_id = l_item_id
          AND mmpn.organization_id = l_org_id;

       -- Finally, we generate our indexed text, which consists
       -- of basic XML-style tags to enclose the different information
       l_text := '<item>' || l_item_code || '</item>' ||
                 '<desc><shortdesc>' || l_description || '</shortdesc>' ||
                 '<longdesc>' || l_long_description || '</longdesc></desc>' ||
                 '<cat>' || l_item_catalog_group || '</cat>';

       IF (l_mfg_table.count = 0) THEN
         l_text := l_text || '<aml><mfg></mfg><mpn></mpn></aml>';
       ELSE
         FOR i IN 1..l_mfg_table.count
         LOOP
           l_text := l_text || '<aml><mfg>' || l_mfg_table(i) || '</mfg><mpn>' ||
                     l_mpn_table(i) || '</mpn></aml>';
         END LOOP;
       END IF;

       --Bug 5094325 begin
       --Now adding section data for lang and org sections
       l_text := l_text || '<lang>:' || l_language || '</lang>';
       l_text := l_text || '<org>:' || l_org_id || '</org>';
       --Bug 5094325 end

       IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
          l_text := TRANSLATE(l_text, '_*~^.$#@:|&', '----+++++++');
       END IF;

     EXCEPTION
        WHEN no_data_found THEN
           IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 0: ' || SQLERRM); END IF;
     END;

     EGO_ITEM_TEXT_PVT.Log_Line('Get_Item_Text: returning text->'||l_text);
     Append_VARCHAR_to_LOB (x_tlob, '', 'BEGIN');
     Append_VARCHAR_to_LOB (x_tlob, l_text);
     Append_VARCHAR_to_LOB (x_tlob, ' ', 'END');

   END IF;

/*
   -----------------------------------------------------------
   -- Concatenate section data and write into LOB
   -----------------------------------------------------------

   IF ( l_id_type = g_Internal_Type ) THEN
      l_Tag_Id_type := Tag_internal;
   ELSIF ( l_id_type = g_Customer_Type ) THEN
      l_Tag_Id_type := Tag_customer;
   ELSE
      l_Tag_Id_type := Tag_reference;
   END IF;

      l_Tag_catalog_group       := Tag_cataloggroupid_prefix || TO_CHAR(l_item_catalog_group_id);
      l_Tag_begin_catalog_group := '<'  || l_Tag_catalog_group || '>';
      l_Tag_end_catalog_group   := '</' || l_Tag_catalog_group || '>';

   --v_item_code := l_item_code || ' ' || l_item_segments;

          x_tchar := '<'  || l_Tag_Id_type || '>' ||
                        l_Tag_begin_catalog_group ||
                           Tag_begin_itemcode || v_item_code || Tag_end_itemcode ||
                           Tag_begin_description ||
                              Tag_begin_shortdescr || v_description || Tag_end_shortdescr ||
                              Tag_begin_longdescr || v_long_description || Tag_end_longdescr ||
                           Tag_end_description ||
                        l_Tag_end_catalog_group ||
                     '</' || l_Tag_Id_type || '>';
*/

/*
   ------------------------------------------------------------------------
   -- Get item text data for inventory, customer, or cross_reference item.
   ------------------------------------------------------------------------

   IF ( l_id_type = g_Internal_Type ) THEN

      l_Tag_Id_type := Tag_internal;

      l_Tag_catalog_group       := Tag_cataloggroupid_prefix || TO_CHAR(l_item_catalog_group_id);
      l_Tag_begin_catalog_group := '<'  || l_Tag_catalog_group || '>';
      l_Tag_end_catalog_group   := '</' || l_Tag_catalog_group || '>';

      ---------------------------------------------------------------
      -- (1) Get text for inventory item row
      ---------------------------------------------------------------

      BEGIN

         SELECT
            SEGMENT1  ||' '|| SEGMENT2  ||' '|| SEGMENT3  ||' '|| SEGMENT4  ||' '|| SEGMENT5  ||' '||
            SEGMENT6  ||' '|| SEGMENT7  ||' '|| SEGMENT8  ||' '|| SEGMENT9  ||' '|| SEGMENT10 ||' '||
            SEGMENT11 ||' '|| SEGMENT12 ||' '|| SEGMENT13 ||' '|| SEGMENT14 ||' '|| SEGMENT15 ||' '||
            SEGMENT16 ||' '|| SEGMENT17 ||' '|| SEGMENT18 ||' '|| SEGMENT19 ||' '|| SEGMENT20
         INTO
            l_item_segments
         FROM
            mtl_system_items_b    msib
         WHERE
                msib.inventory_item_id = l_item_id
            AND msib.organization_id   = l_org_id;

         SELECT
            msitl.description, msitl.long_description
         INTO
            v_description, v_long_description
         FROM
            mtl_system_items_tl   msitl
         WHERE
                msitl.inventory_item_id = l_item_id
            AND msitl.organization_id   = l_org_id
            AND msitl.language          = l_language;

         -- Only include item code if found in the referenced table
         v_item_code := l_item_code || ' ' || l_item_segments;

      EXCEPTION
         WHEN no_data_found THEN
            IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 1: ' || SQLERRM); END IF;
      END;

   ELSIF ( l_id_type = g_Customer_Type ) THEN

      l_Tag_Id_type := Tag_customer;

      ---------------------------------------------------------------
      -- (2) Get text data for customer item;
      --     customer_item_id is the Unique Key column;
      --     customer item is org-independent (eitl.organization_id = 0).
      ---------------------------------------------------------------

      BEGIN

         SELECT
            customer_item_desc, NULL
         INTO
            v_description, v_long_description
         FROM
            mtl_customer_items
         WHERE
            customer_item_id = l_item_id;

         -- ego_item_text_tl would not contain inactive customer items, so this is commented out:
         --   AND inactive_flag = 'N';

         -- Only include item code if found in the referenced table
         v_item_code := l_item_code;

      EXCEPTION
         WHEN no_data_found THEN
            IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 2: ' || SQLERRM); END IF;
      END;

   ELSE
      -- All reference types

      l_Tag_Id_type := Tag_reference;

      ---------------------------------------------------------------
      -- (3) Get text data for cross_reference item;
      --     the Unique Key columns are:
      --        cross_reference_type
      --        cross_reference
      --        organization_id
      --        inventory_item_id;
      --     cross_reference item can be either org-dependent
      --     or org-independent (org_id = 0).
      ---------------------------------------------------------------

      BEGIN

         SELECT
            description, NULL
         INTO
            v_description, v_long_description
         FROM
            mtl_cross_references
         WHERE
                cross_reference_type = l_id_type
            AND cross_reference = l_item_code
            AND inventory_item_id = l_item_id
            AND org_independent_flag = DECODE(l_org_id, 0, 'Y', 'N')
            AND (    organization_id = l_org_id
                  OR ( organization_id IS NULL AND l_org_id = 0 )
                )
         ;

         -- Only include item code if found in the referenced table
         v_item_code := l_item_code;

      EXCEPTION
         WHEN no_data_found THEN
            IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 3: ' || SQLERRM); END IF;
      END;

   END IF;  -- identifier type

   l_Tag_begin_Id_type := '<'  || l_Tag_Id_type || '>';
   l_Tag_end_Id_type   := '</' || l_Tag_Id_type || '>';

   -----------------------------------------------------------
   -- Concatenate section data and write into LOB
   -----------------------------------------------------------

   IF ( p_output_type = 'VARCHAR2' ) THEN
      x_tchar := '';
   ELSE
      Append_VARCHAR_to_LOB (x_tlob, '', 'BEGIN');
   END IF;

   IF ( ( Length(NVL(v_item_code,0)) + Length(NVL(v_description,0)) + Length(NVL(v_long_description,0)) ) > 0 ) THEN

      IF ( l_id_type = g_Internal_Type ) THEN

         ----------------------------------------------------
         -- For id type INTERNAL, add catalog group section
         ----------------------------------------------------

         l_buffer := l_Tag_begin_Id_type ||  l_Tag_begin_catalog_group ||
                        Tag_begin_itemcode || v_item_code || Tag_end_itemcode ||
                        Tag_begin_description ||
                           Tag_begin_shortdescr || v_description || Tag_end_shortdescr ||
                           Tag_begin_longdescr || v_long_description || Tag_end_longdescr ||
                        Tag_end_description;

         IF ( p_output_type = 'VARCHAR2' ) THEN  x_tchar := x_tchar || l_buffer;
                                           ELSE  Append_VARCHAR_to_LOB (x_tlob, l_buffer);  END IF;
*/

/*
         ------------------------------------------------------------------------------------
         -- Get user-defined attribute display names and values (for id type INTERNAL only)
         ------------------------------------------------------------------------------------

         BEGIN

         -- If this is index creation, use different approach to retrieve
         -- user-defined attribute data.

         IF ( g_Indexing_Context = 'CREATE_INDEX' ) THEN

            FOR ext_id_rec IN Ext_Attr_Extension_Ids_cur ( p_inventory_item_id => l_item_id
                                                         , p_organization_id => l_org_id )
            LOOP
               l_buffer := g_Item_Ext_Text_Tbl (ext_id_rec.EXTENSION_ID);

               IF ( p_output_type = 'VARCHAR2' ) THEN  x_tchar := x_tchar || l_buffer;
                                                 ELSE  Append_VARCHAR_to_LOB (x_tlob, l_buffer);  END IF;

            END LOOP;  -- Ext_Attr_Extension_Ids_cur

         ELSE

            FOR attr_rec IN Ext_Attr_Internal_Values_cur (l_item_id, l_org_id, l_language) LOOP

               IF ( attr_rec.FLEX_VALUE_SET_ID IS NULL ) THEN

                  l_buffer := Tag_begin_userattribute ||
                                 attr_rec.ATTR_DISPLAY_NAME || ' ' || attr_rec.ATTR_INTERNAL_VALUE ||
                              Tag_end_userattribute;

               ELSE

                  FOR lookup_rec IN Ext_Attr_Lookup_Values_cur ( attr_rec.FLEX_VALUE_SET_ID
                                                               , attr_rec.ATTR_INTERNAL_VALUE
                                                               , l_language)
                  LOOP

                     l_buffer := Tag_begin_userattribute ||
                                    attr_rec.ATTR_DISPLAY_NAME || ' ' || lookup_rec.ATTR_LOOKUP_VALUE ||
                                 Tag_end_userattribute;

                  END LOOP;  -- Ext_Attr_Lookup_Values_cur

               END IF;  -- FLEX_VALUE_SET_ID IS NULL

               IF ( p_output_type = 'VARCHAR2' ) THEN  x_tchar := x_tchar || l_buffer;
                                                 ELSE  Append_VARCHAR_to_LOB (x_tlob, l_buffer);  END IF;

            END LOOP;  -- Ext_Attr_Internal_Values_cur

         END IF;  -- g_Indexing_Context

         EXCEPTION
            WHEN no_data_found THEN
               IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 1: ' || SQLERRM); END IF;

         END;  -- user-defined attributes
*/

/*
         l_buffer := l_Tag_end_catalog_group || l_Tag_end_Id_type;

         IF ( p_output_type = 'VARCHAR2' ) THEN  x_tchar := x_tchar || l_buffer;
                                           ELSE  Append_VARCHAR_to_LOB (x_tlob, l_buffer);  END IF;

      ELSE

         l_buffer := l_Tag_begin_Id_type ||
                        Tag_begin_itemcode || v_item_code || Tag_end_itemcode ||
                        Tag_begin_description ||
                           Tag_begin_shortdescr || v_description || Tag_end_shortdescr ||
                           Tag_begin_longdescr || v_long_description || Tag_end_longdescr ||
                        Tag_end_description ||
                     l_Tag_end_Id_type;

         IF ( p_output_type = 'VARCHAR2' ) THEN  x_tchar := x_tchar || l_buffer;
                                           ELSE  Append_VARCHAR_to_LOB (x_tlob, l_buffer);  END IF;

      END IF;  -- Id type is Internal

      -- Complete writing item text data into LOB.
      --
      IF ( p_output_type = 'VARCHAR2' ) THEN
         x_tchar := x_tchar || ' ';
      ELSE
         Append_VARCHAR_to_LOB (x_tlob, ' ', 'END');
      END IF;

   ELSE
      -- If v_item_code, v_description, v_long_description is null/empty,
      -- just write a space.

      -- Complete writing item text data into LOB.
      --
      IF ( p_output_type = 'VARCHAR2' ) THEN
         x_tchar := x_tchar || ' ';
      ELSE
         Append_VARCHAR_to_LOB (x_tlob, ' ', 'END');
      END IF;

   END IF;  -- item text data is not null
*/

EXCEPTION

   WHEN others THEN
      --EGO_ITEM_TEXT_UTIL.Log_Error ('SQL_ERROR', SQLERRM);
      --IF (g_Debug) THEN Debug(l_item_id, l_org_id, l_item_code, '** 9: ' || SQLERRM); END IF;
      RAISE;

END Get_Item_Text;


-- -----------------------------------------------------------------------------
--          Debug
-- -----------------------------------------------------------------------------

PROCEDURE Debug
(
   p_item_id       IN    NUMBER
,  p_org_id        IN    NUMBER
,  p_msg_name      IN    VARCHAR2
,  p_error_text    IN    VARCHAR2
)
IS
   l_sysdate       DATE  :=  SYSDATE;
BEGIN

   INSERT INTO mtl_interface_errors
   (
      transaction_id
   ,  unique_id
   ,  organization_id
   ,  table_name
   ,  message_name
   ,  error_message
   ,  creation_date
   ,  created_by
   ,  last_update_date
   ,  last_updated_by
   )
   VALUES
   (
      mtl_system_items_interface_s.NEXTVAL
   ,  p_item_id
   ,  p_org_id
   ,  'EGO_ITEM_TEXT_TL'
   ,  p_msg_name
   ,  SUBSTRB(p_error_text, 1,240)
   ,  l_sysdate
   ,  1
   ,  l_sysdate
   ,  1
   );

END Debug;

-- -----------------------------------------------------------------------------
--            Print_Lob
-- -----------------------------------------------------------------------------

PROCEDURE Print_Lob ( p_tlob_loc  IN  CLOB )
IS
   l_amount       BINARY_INTEGER    :=  255;
   l_offset       INTEGER           :=  1;
   l_offset_max   INTEGER           :=  32767;
   l_buffer       VARCHAR2(32767);
BEGIN

   --DBMS_OUTPUT.put_line('LOB contents:');

   -- Read portions of LOB
   LOOP
      DBMS_LOB.Read (  lob_loc  =>  p_tlob_loc
                    ,  amount   =>  l_amount
                    ,  offset   =>  l_offset
                    ,  buffer   =>  l_buffer
                    );

      --DBMS_OUTPUT.put_line(l_buffer);

      l_offset := l_offset + l_amount;
      EXIT WHEN l_offset > l_offset_max;
   END LOOP;

EXCEPTION
   WHEN no_data_found THEN
      NULL;

END Print_Lob;

-- -----------------------------------------------------------------------------
--          Sync_Index
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL )
IS
BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(log_level => FND_LOG.LEVEL_PROCEDURE
                  ,module    => 'fnd.plsql.EGO_ITEM_TEXT_UTIL.SYNC_INDEX'
                  ,message   => 'Before Calling the AD_CTX_DDL.Sync_Index'
                  );
   END IF;

   -------------------------------------------------------------------------------
   -- Use CTX API instead of alter index to resolve a problem of separate
   -- sync and optimize jobs causing conflict because two alter index operations
   -- cannot cannot be run at the same time for a single index.
   -------------------------------------------------------------------------------
   --EXECUTE IMMEDIATE 'ALTER INDEX ' || g_Index_Owner ||'.'|| g_Index_Name || ' REBUILD ONLINE PARAMETERS (''SYNC'')';

   AD_CTX_DDL.Sync_Index ( idx_name  =>  NVL(p_idx_name, g_Index_Owner ||'.'|| g_Index_Name) );

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     fnd_log.string(log_level => FND_LOG.LEVEL_PROCEDURE
                   ,module    => 'fnd.plsql.EGO_ITEM_TEXT_UTIL.SYNC_INDEX'
                   ,message   => 'After Calling the AD_CTX_DDL.Sync_Index'
                  );
   END IF;
/*
EXCEPTION
   WHEN others THEN
      NULL;
      DBMS_OUTPUT.put_line('==> Sync_Index(p_idx_name): EXCEPTION: ' || SQLERRM);
*/
END Sync_Index;

-- -----------------------------------------------------------------------------
--          Optimize_Index
-- -----------------------------------------------------------------------------

-- Start : Concurrent Program for Optimize iM index
PROCEDURE Optimize_Index
(
   ERRBUF      OUT NOCOPY VARCHAR2
,  RETCODE     OUT NOCOPY NUMBER
,  p_optlevel  IN         VARCHAR2 DEFAULT  AD_CTX_DDL.Optlevel_Full
,  p_dummy     IN         VARCHAR2 DEFAULT  NULL
,  p_maxtime   IN         NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
)
IS

   Mctx        INV_ITEM_MSG.Msg_Ctx_type;
   l_api_name  CONSTANT  VARCHAR2(30)  := 'Optimize_Index';
   l_success   CONSTANT  NUMBER :=  0;
   l_error     CONSTANT  NUMBER :=  2;
   l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_maxtime             NUMBER := NVL(p_maxtime,AD_CTX_DDL.Maxtime_Unlimited);

BEGIN

   INV_ITEM_MSG.Initialize;
   INV_ITEM_MSG.set_Message_Mode ('CP_LOG');

   -- Set message level
   INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Error);

   -- Define message context
   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'Started AD_CTX_DDL.Optimize_Index..');
      INV_ITEM_MSG.Debug(Mctx, 'Optimization Level        :'||p_optlevel);
      INV_ITEM_MSG.Debug(Mctx, 'Maximum Optimization Time :'||p_maxtime);
   END IF;

   --3067433: Maxtime should be null for FAST Optimize mode
   IF p_optlevel ='FAST' THEN
      l_maxtime := NULL;
   END IF;

   AD_CTX_DDL.Optimize_Index ( idx_name  =>  g_Index_Owner ||'.'|| g_Index_Name
                             , optlevel  =>  NVL(p_optlevel,AD_CTX_DDL.Optlevel_Full)
                             , maxtime   =>  l_maxtime);

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'Completed AD_CTX_DDL.Optimize_Index..');
   END IF;

   RETCODE := l_success;
   ERRBUF  := FND_MESSAGE.Get_String('EGO', 'EGO_OPTIMINDEX_SUCCESS');

   -- Write all accumulated messages
   INV_ITEM_MSG.Write_List (p_delete => TRUE);

EXCEPTION
   WHEN OTHERS THEN
      RETCODE := l_error;
      ERRBUF  := FND_MESSAGE.Get_String('EGO', 'EGO_OPTIMINDEX_FAILURE');

      INV_ITEM_MSG.Add_Message
      (  p_Msg_Name        =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,  p_token1          =>  'PACKAGE_NAME'
      ,  p_value1          =>  G_PKG_NAME
      ,  p_token2          =>  'PROCEDURE_NAME'
      ,  p_value2          =>  l_api_name
      ,  p_token3          =>  'ERROR_TEXT'
      ,  p_value3          =>  SUBSTRB(SQLERRM, 1,240));

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

END Optimize_Index;
-- End : Concurrent Program for Optimize iM index

-- -----------------------------------------------------------------------------
--          Process_Source_Table_Event (Wrapper)
-- -----------------------------------------------------------------------------

PROCEDURE Process_Source_Table_Event
(
   p_table_name              IN  VARCHAR2
,  p_event                   IN  VARCHAR2
,  p_scope                   IN  VARCHAR2
,  p_manufacturer_id         IN NUMBER
,  p_old_item_id             IN NUMBER
,  p_item_id                 IN  NUMBER
,  p_org_id                  IN  NUMBER
,  p_language                IN  VARCHAR2
,  p_source_lang             IN  VARCHAR2
,  p_last_update_date        IN  VARCHAR2
,  p_last_updated_by         IN  VARCHAR2
,  p_last_update_login       IN  VARCHAR2
,  p_id_type                 IN  VARCHAR2
,  p_item_code               IN  VARCHAR2
,  p_item_catalog_group_id   IN  VARCHAR2
)
IS
   l_id_type         VARCHAR2(30);
   l_text_ins        VARCHAR2(1)  :=  '1';
   l_text_upd        VARCHAR2(1)  :=  '2';
BEGIN
   --DBMS_OUTPUT.put_line('==> p_table_name = '|| p_table_name || '  p_event = ' || p_event || '  p_scope = ' || p_scope);

   IF ( p_scope = 'ROW' ) THEN

      IF ( p_table_name IN ('MTL_SYSTEM_ITEMS_B', 'MTL_SYSTEM_ITEMS_TL',
                            'EGO_MTL_SY_ITEMS_EXT_B', 'EGO_MTL_SY_ITEMS_EXT_TL',
                            'MTL_ITEM_CATALOG_GROUPS_B') ) THEN
         l_id_type := g_Internal_Type;
      ELSIF ( p_table_name = 'MTL_CUSTOMER_ITEMS' ) THEN
         l_id_type := g_Customer_Type;
      ELSIF ( p_table_name = 'MTL_CROSS_REFERENCES' ) THEN
         l_id_type := p_id_type;
      ELSIF( p_table_name IN ('MTL_MANUFACTURERS', 'MTL_MFG_PART_NUMBERS') ) THEN
         l_id_type := g_Internal_Type;
      END IF;--( p_scope = 'ROW' )

      ------------------------------------
      -- Table MTL_SYSTEM_ITEMS_B events
      ------------------------------------

      IF ( p_table_name = 'MTL_SYSTEM_ITEMS_B' ) THEN

         IF ( p_event = 'UPDATE' ) THEN

            -- Item Code is passed in through a parameter.
            -- Update rows for all languages.

            UPDATE ego_item_text_tl
            SET
               item_code              =  DECODE(p_item_code, FND_API.G_MISS_CHAR, item_code, p_item_code)
            ,  item_catalog_group_id  =  DECODE(p_item_catalog_group_id, FND_API.G_MISS_NUM, item_catalog_group_id, p_item_catalog_group_id)
            ,  text                   =  l_text_upd
            ,  last_update_date       =  SYSDATE
            ,  last_updated_by        =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
            ,  last_update_login      =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
            WHERE
                   id_type  = l_id_type
               AND item_id  = p_item_id
               AND org_id   = p_org_id;

         END IF;  -- p_event

      -------------------------------------
      -- Table MTL_SYSTEM_ITEMS_TL events
      -------------------------------------

      ELSIF ( p_table_name = 'MTL_SYSTEM_ITEMS_TL' ) THEN

         --------------------------------------------------------------------
         -- When invoked from the trigger, "mutating table" is not an issue
         -- here because there is no select from mtl_system_items_tl.
         --------------------------------------------------------------------

         IF ( p_event = 'INSERT' ) THEN

            INSERT INTO ego_item_text_tl
            (
               id_type
            ,  item_id
            ,  item_code
            ,  org_id
            ,  language
            ,  source_lang
            ,  item_catalog_group_id
            ,  inventory_item_id
            ,  text
            ,  creation_date
            ,  created_by
            ,  last_update_date
            ,  last_updated_by
            ,  last_update_login
            )
            SELECT
               l_id_type
            ,  msik.inventory_item_id
            ,  msik.concatenated_segments
            ,  msik.organization_id
            ,  p_language
            ,  DECODE(p_source_lang, FND_API.G_MISS_CHAR, p_language, p_source_lang)
            ,  msik.item_catalog_group_id
            ,  msik.inventory_item_id
            ,  l_text_ins
            ,  SYSDATE
            ,  msik.created_by
            ,  SYSDATE
            ,  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, msik.last_updated_by,   p_last_updated_by)
            ,  DECODE(p_last_update_login, FND_API.G_MISS_NUM, msik.last_update_login, p_last_update_login)
            FROM
               mtl_system_items_b_kfv  msik
            WHERE
                   msik.inventory_item_id  = p_item_id
               AND msik.organization_id    = p_org_id;
      /*  Bug: 4667452  Commenting out following conditions
               AND msik.concatenated_segments IS NOT NULL
               AND NOT EXISTS
                   ( SELECT 1 FROM ego_item_text_tl eitl1
                     WHERE
                            eitl1.id_type   = l_id_type
                        AND eitl1.item_id   = msik.inventory_item_id
                        AND eitl1.item_code = msik.concatenated_segments
                        AND eitl1.org_id    = msik.organization_id
                        AND eitl1.language  = p_language
                   );
       End Bug: 4667452  */

         ELSIF ( p_event = 'UPDATE' ) THEN

            UPDATE ego_item_text_tl
            SET
               source_lang       =  DECODE(p_source_lang, FND_API.G_MISS_CHAR, source_lang, p_source_lang)
            ,  text              =  l_text_upd
            ,  last_update_date  =  SYSDATE
            ,  last_updated_by   =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
            ,  last_update_login =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
            WHERE
                   id_type  = l_id_type
               AND item_id  = p_item_id
               AND org_id   = p_org_id
               AND language = p_language;

         ELSIF ( p_event = 'DELETE' ) THEN

            DELETE FROM ego_item_text_tl
            WHERE
                   id_type  = l_id_type
               AND item_id  = p_item_id
               AND org_id   = p_org_id
               AND language = p_language;

         END IF;  -- p_event


      -------------------------------------
      -- Table MTL_MANUFACTURERS events
      -------------------------------------

      ELSIF ( p_table_name = 'MTL_MANUFACTURERS' ) THEN
              IF (p_manufacturer_id IS NOT NULL) THEN

                UPDATE  EGO_ITEM_TEXT_TL
                            SET  text                     =  l_text_upd
                                ,  last_update_date       =  SYSDATE
                                ,  last_updated_by        =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
                                ,  last_update_login      =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
                  WHERE
                           id_type  = l_id_type
                           AND (item_id,org_id) IN ( SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID
                                                     FROM   MTL_MFG_PART_NUMBERS
                                                     WHERE  MANUFACTURER_ID = p_manufacturer_id );
              END IF;



      -------------------------------------
      -- Table MTL_MFG_PART_NUMBERS events
      -------------------------------------

      ELSIF ( p_table_name = 'MTL_MFG_PART_NUMBERS' ) THEN

         IF ( p_event = 'UPDATE' OR  p_event= 'INSERT' ) THEN


                  UPDATE  EGO_ITEM_TEXT_TL
                            SET  text                     =  l_text_upd
                                ,  last_update_date       =  SYSDATE
                                ,  last_updated_by        =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
                                ,  last_update_login      =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
                  WHERE
                           id_type  = l_id_type
                           AND org_id   = p_org_id
                           AND item_id IN (NVL(p_old_item_id,p_item_id),p_item_id);

          ELSE
                  UPDATE  EGO_ITEM_TEXT_TL
                            SET  text                     =  l_text_upd
                                ,  last_update_date       =  SYSDATE
                  WHERE
                           id_type  = l_id_type
                           AND org_id   = p_org_id
                           AND item_id IN (NVL(p_old_item_id,p_item_id),p_item_id);
    END IF;  -- p_event




/*
      ----------------------------------------
      -- Table EGO_MTL_SY_ITEMS_EXT_% events
      ----------------------------------------

      ELSIF ( p_table_name = 'EGO_MTL_SY_ITEMS_EXT_B' ) THEN
         IF ( p_event IN ('INSERT', 'UPDATE', 'DELETE') ) THEN
            --
            -- Update rows for all languages
            --
            UPDATE ego_item_text_tl
            SET
               text              =  l_text_upd
            ,  last_update_date  =  SYSDATE
            WHERE
                   id_type  = l_id_type
               AND item_id  = p_item_id
               AND org_id   = p_org_id;

         END IF;

      ELSIF ( p_table_name = 'EGO_MTL_SY_ITEMS_EXT_TL' ) THEN
         IF ( p_event IN ('INSERT', 'UPDATE', 'DELETE') ) THEN
            --
            -- Update rows for a single language
            --
            UPDATE ego_item_text_tl
            SET
               text              =  l_text_upd
            ,  last_update_date  =  SYSDATE
            WHERE
                   id_type  = l_id_type
               AND item_id  = p_item_id
               AND org_id   = p_org_id
               AND language = p_language;

         END IF;
*/
      ELSIF ( p_table_name = 'MTL_ITEM_CATALOG_GROUPS_B' ) THEN

         IF ( p_event = 'UPDATE' ) THEN

            -- updated item catalog group ID is passed in through a parameter;
            -- update rows for all languages.

            UPDATE ego_item_text_tl
            SET
               text                   =  l_text_upd
            ,  last_update_date       =  SYSDATE
            ,  last_updated_by        =  DECODE(p_last_updated_by,   FND_API.G_MISS_NUM, last_updated_by, p_last_updated_by)
            ,  last_update_login      =  DECODE(p_last_update_login, FND_API.G_MISS_NUM, last_update_login, p_last_update_login)
            WHERE
                   id_type  = l_id_type
               AND item_catalog_group_id = NVL(p_item_catalog_group_id, -1);

         END IF;  -- p_event

      END IF;  -- p_table_name

   -------------------------------------------------------------------------
   -- Sync the index after the statement level event on a source table.
   -- This should no longer be used.
   -------------------------------------------------------------------------
   --ELSIF ( p_scope IN ('STATEMENT', 'STMT') ) THEN
   --   AD_CTX_DDL.Sync_Index ( idx_name  =>  g_Index_Owner ||'.'|| g_Index_Name );

   ELSE
      Raise_Application_Error (-20001, 'Process_Source_Table_Event: Invalid parameter value: p_scope = ' || p_scope);

   END IF;  -- p_scope

EXCEPTION

   WHEN others THEN
      --Raise_Application_Error (-20001, 'Process_Source_Table_Event: ' || SQLERRM);
      RAISE;

END Process_Source_Table_Event;

-- -----------------------------------------------------------------------------
--          get_Prod_Schema
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_Prod_Schema);
END get_Prod_Schema;

-- -----------------------------------------------------------------------------
--          Process_Source_Table_Event
-- -----------------------------------------------------------------------------

PROCEDURE Process_Source_Table_Event
(
   p_table_name              IN  VARCHAR2
,  p_event                   IN  VARCHAR2
,  p_scope                   IN  VARCHAR2
,  p_item_id                 IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
,  p_org_id                  IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
,  p_language                IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_source_lang             IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_last_update_date        IN  VARCHAR2    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by         IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login       IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_id_type                 IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_item_code               IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_item_catalog_group_id   IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
)
IS

l_manufacturer_id NUMBER :=NULL;
l_old_item_id NUMBER :=NULL;
BEGIN
        EGO_ITEM_TEXT_UTIL.Process_Source_Table_Event
        (
           p_table_name => p_table_name
        ,  p_event =>p_event
        ,  p_scope => p_scope
        ,  p_manufacturer_id => l_manufacturer_id
        ,  p_old_item_id => l_old_item_id
        ,  p_item_id => p_item_id
        ,  p_org_id => p_org_id
        ,  p_language => p_language
        ,  p_source_lang => p_source_lang
        ,  p_last_update_date => p_last_update_date
        ,  p_last_updated_by => p_last_updated_by
        ,  p_last_update_login => p_last_update_login
        ,  p_id_type => p_id_type
        ,  p_item_code => p_item_code
        ,  p_item_catalog_group_id => p_item_catalog_group_id
        );
END Process_Source_Table_Event;


-- -----------------------------------------------------------------------------
--        get_DB_Version_Num
-- -----------------------------------------------------------------------------

FUNCTION get_DB_Version_Num
RETURN NUMBER
IS
BEGIN
   RETURN (g_DB_Version_Num);
END get_DB_Version_Num;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_DB_Version_Str);
END get_DB_Version_Str;

-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN

   ------------------------------------------------------------------
   -- Determine index schema and store in a private global variable
   ------------------------------------------------------------------

   g_installed := FND_INSTALLATION.Get_App_Info ('EGO', g_inst_status, g_industry, g_Prod_Schema);

   g_Index_Owner := g_Prod_Schema;

   -------------------------
   -- Determine DB version
   -------------------------
   --Bug 4045988: We need to convert the db version string to be compativle with the
     --numeric characters of that language. Eg. '9.2' need to be changed to '9F2'
     -- in French before we can use it in TO_NUMBER
   DBMS_UTILITY.db_Version (g_DB_Version_Str, g_compatibility);
   l_DB_Version_Str := SUBSTR(g_DB_Version_Str, 1, INSTR(g_DB_Version_Str, '.', 1, 2) - 1);
   SELECT SUBSTR(VALUE,0,1) into l_DB_Numeric_Character
     FROM V$NLS_PARAMETERS
     Where PARAMETER = 'NLS_NUMERIC_CHARACTERS';
   g_DB_Version_Num := TO_NUMBER( REPLACE(l_DB_Version_Str, '.', l_DB_Numeric_Character) );

/*
   BEGIN
      SELECT concatenated_segment_delimiter
        INTO g_MSTK_Flex_Delimiter
      FROM fnd_id_flex_structures
      WHERE
             application_id = 401
         AND id_flex_code   = 'MSTK'
         AND id_flex_num    = 101
         AND enabled_flag   = 'Y';
   EXCEPTION
      WHEN others THEN
         g_MSTK_Flex_Delimiter := ' ';
   END;
*/

END EGO_ITEM_TEXT_UTIL;

/

  GRANT EXECUTE ON "APPS"."EGO_ITEM_TEXT_UTIL" TO "CTXSYS";
