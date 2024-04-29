--------------------------------------------------------
--  DDL for Package Body HXC_DEPOSIT_WRAPPER_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DEPOSIT_WRAPPER_UTILITIES" AS
/* $Header: hxcdpwrut.pkb 120.12.12010000.5 2009/12/31 10:20:29 amakrish ship $ */


g_separator VARCHAR2(2) := '|';
g_pref_sep VARCHAR2(2) := '#';
g_package  VARCHAR2(50) := 'hxc_deposit_wrapper_utilities';

g_debug boolean :=hr_utility.debug_enabled;

-- globals for caching the hours type poplist
g_ht_resource_id varchar2(20) :=null;
g_ht_start_time  varchar2(30) :=null;
g_ht_stop_time   varchar2(30) :=null;
g_ht_alias_or_element_id  varchar2(30) :=null;
g_ht_resp_id number := null;
g_hours_type_list varchar2(15000) :=null;
g_ht_time date := sysdate;
--


G_TS_PER_APPROVAL_STYLE1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TS_PER_APPROVAL_STYLE2 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_ST_ALW_EDITS1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_LAYOUT1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_LAYOUT2 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_LAYOUT3 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_NUM_EMTY_RWS1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_APND_ON_TCRD1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_CREATE1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_DFLT_VAL_ADMIN1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_DFLT_VAL_USR1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_SV_ON_TCRD1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TMPLT_FCNLTY1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_NUM_RCNT_TCRDS1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_DISCNCTD_ENTRY1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_ALW_NEG_TIME1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_UOM1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_UOM2 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_ST_ALW_EDITS6 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_ST_ALW_EDITS11 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_LAYOUT4 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_APRVR_ENBLE_OVRD1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_APRVR_DFLT_OVRD1 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_TCRD_LAYOUT5 hxc_pref_hierarchies.attribute1%type := 'null';
G_TC_W_RULES_EVALUATION1 hxc_pref_hierarchies.attribute1%type := 'null';


PROCEDURE initialize_globals is

BEGIN

G_TS_PER_APPROVAL_STYLE1 := 'null';
G_TS_PER_APPROVAL_STYLE2 := 'null';
G_TC_W_TCRD_ST_ALW_EDITS1 := 'null';
G_TC_W_TCRD_LAYOUT1 := 'null';
G_TC_W_TCRD_LAYOUT2 := 'null';
G_TC_W_TCRD_LAYOUT3 := 'null';
G_TC_W_TCRD_NUM_EMTY_RWS1 := 'null';
G_TC_W_TMPLT_APND_ON_TCRD1 := 'null';
G_TC_W_TMPLT_CREATE1 := 'null';
G_TC_W_TMPLT_DFLT_VAL_ADMIN1 := 'null';
G_TC_W_TMPLT_DFLT_VAL_USR1 := 'null';
G_TC_W_TMPLT_SV_ON_TCRD1 := 'null';
G_TC_W_TMPLT_FCNLTY1 := 'null';
G_TC_W_NUM_RCNT_TCRDS1 := 'null';
G_TC_W_DISCNCTD_ENTRY1 := 'null';
G_TC_W_ALW_NEG_TIME1 := 'null';
G_TC_W_TCRD_UOM1 := 'null';
G_TC_W_TCRD_UOM2 := 'null';
G_TC_W_TCRD_ST_ALW_EDITS6 := 'null';
G_TC_W_TCRD_ST_ALW_EDITS11 := 'null';
G_TC_W_TCRD_LAYOUT4 := 'null';
G_TC_W_APRVR_ENBLE_OVRD1 := 'null';
G_TC_W_APRVR_DFLT_OVRD1 := 'null';
G_TC_W_TCRD_LAYOUT5 := 'null';
G_TC_W_RULES_EVALUATION1 := 'null';

END initialize_globals;

FUNCTION splat_preferences return varchar2 is

BEGIN

return
G_TS_PER_APPROVAL_STYLE1||g_pref_sep||
G_TS_PER_APPROVAL_STYLE2||g_pref_sep||
G_TC_W_TCRD_ST_ALW_EDITS1||g_pref_sep||
G_TC_W_TCRD_LAYOUT1||g_pref_sep||
G_TC_W_TCRD_LAYOUT2||g_pref_sep||
G_TC_W_TCRD_LAYOUT3||g_pref_sep||
G_TC_W_TCRD_NUM_EMTY_RWS1||g_pref_sep||
G_TC_W_TMPLT_APND_ON_TCRD1||g_pref_sep||
G_TC_W_TMPLT_CREATE1||g_pref_sep||
G_TC_W_TMPLT_DFLT_VAL_ADMIN1||g_pref_sep||
G_TC_W_TMPLT_DFLT_VAL_USR1||g_pref_sep||
G_TC_W_TMPLT_SV_ON_TCRD1||g_pref_sep||
G_TC_W_TMPLT_FCNLTY1||g_pref_sep||
G_TC_W_NUM_RCNT_TCRDS1||g_pref_sep||
G_TC_W_DISCNCTD_ENTRY1||g_pref_sep||
G_TC_W_ALW_NEG_TIME1||g_pref_sep||
G_TC_W_TCRD_UOM1||g_pref_sep||
G_TC_W_TCRD_UOM2||g_pref_sep||
G_TC_W_TCRD_ST_ALW_EDITS6||g_pref_sep||
G_TC_W_TCRD_ST_ALW_EDITS11||g_pref_sep||
G_TC_W_TCRD_LAYOUT4||g_pref_sep||
G_TC_W_APRVR_ENBLE_OVRD1||g_pref_sep||
G_TC_W_APRVR_DFLT_OVRD1||g_pref_sep||
G_TC_W_TCRD_LAYOUT5||g_pref_sep||
G_TC_W_RULES_EVALUATION1;

END splat_preferences;

PROCEDURE set_pref_globals
           (p_prefs in HXC_PREFERENCE_EVALUATION.T_PREF_TABLE
           ) is

i NUMBER;
l_proc VARCHAR2(30) := 'SET_PREF_GLOBALS';

BEGIN

initialize_globals;

i := p_prefs.first;

LOOP

  EXIT WHEN NOT p_prefs.exists(i);

  if(p_prefs(i).preference_code='TS_PER_APPROVAL_STYLE') then
   if(G_TS_PER_APPROVAL_STYLE1 = 'null') then
    G_TS_PER_APPROVAL_STYLE1 := nvl(p_prefs(i).attribute1,'null');
   end if;
   if(G_TS_PER_APPROVAL_STYLE2='null') then
    G_TS_PER_APPROVAL_STYLE2 := nvl(p_prefs(i).attribute2,'null');
    end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TCRD_ST_ALW_EDITS') then
   if(G_TC_W_TCRD_ST_ALW_EDITS1 ='null') then
    G_TC_W_TCRD_ST_ALW_EDITS1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TCRD_LAYOUT') then
   if(G_TC_W_TCRD_LAYOUT1 ='null') then
    G_TC_W_TCRD_LAYOUT1 := nvl(p_prefs(i).attribute1,'null');
   end if;
   if(G_TC_W_TCRD_LAYOUT2 ='null') then
    G_TC_W_TCRD_LAYOUT2 := nvl(p_prefs(i).attribute2,'null');
   end if;
   if(G_TC_W_TCRD_LAYOUT3 ='null') then
    G_TC_W_TCRD_LAYOUT3 := nvl(p_prefs(i).attribute3,'null');
   end if;
   if(G_TC_W_TCRD_LAYOUT4 ='null') then
    G_TC_W_TCRD_LAYOUT4 := nvl(p_prefs(i).attribute4,'null');
   end if;
   if(G_TC_W_TCRD_LAYOUT5 ='null') then
    G_TC_W_TCRD_LAYOUT5 := nvl(p_prefs(i).attribute5,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TCRD_NUM_EMTY_RWS') then
   if(G_TC_W_TCRD_NUM_EMTY_RWS1 ='null') then
    G_TC_W_TCRD_NUM_EMTY_RWS1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_APND_ON_TCRD') then
   if(G_TC_W_TMPLT_APND_ON_TCRD1 ='null') then
    G_TC_W_TMPLT_APND_ON_TCRD1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_CREATE') then
   if(G_TC_W_TMPLT_CREATE1 ='null') then
    G_TC_W_TMPLT_CREATE1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_DFLT_VAL_ADMIN') then
   if(G_TC_W_TMPLT_DFLT_VAL_ADMIN1 ='null') then
    G_TC_W_TMPLT_DFLT_VAL_ADMIN1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_DFLT_VAL_USR') then
   if(G_TC_W_TMPLT_DFLT_VAL_USR1 ='null') then
    G_TC_W_TMPLT_DFLT_VAL_USR1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_SV_ON_TCRD') then
   if(G_TC_W_TMPLT_SV_ON_TCRD1 ='null') then
    G_TC_W_TMPLT_SV_ON_TCRD1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TMPLT_FCNLTY') then
   if(G_TC_W_TMPLT_FCNLTY1 ='null') then
    G_TC_W_TMPLT_FCNLTY1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_NUM_RCNT_TCRDS') then
   if(G_TC_W_NUM_RCNT_TCRDS1 ='null') then
    G_TC_W_NUM_RCNT_TCRDS1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_DISCNCTD_ENTRY') then
   if(G_TC_W_DISCNCTD_ENTRY1 ='null') then
    G_TC_W_DISCNCTD_ENTRY1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_ALW_NEG_TIME') then
   if(G_TC_W_ALW_NEG_TIME1 ='null') then
    G_TC_W_ALW_NEG_TIME1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TCRD_UOM') then
   if(G_TC_W_TCRD_UOM1 ='null') then
    G_TC_W_TCRD_UOM1 := nvl(p_prefs(i).attribute1,'null');
   end if;
   if(G_TC_W_TCRD_UOM2 ='null') then
    G_TC_W_TCRD_UOM2 := nvl(p_prefs(i).attribute2,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_TCRD_ST_ALW_EDITS') then
   if(G_TC_W_TCRD_ST_ALW_EDITS6 ='null') then
    G_TC_W_TCRD_ST_ALW_EDITS6 := nvl(p_prefs(i).attribute6,'null');
   end if;
   if(G_TC_W_TCRD_ST_ALW_EDITS11 ='null') then
    G_TC_W_TCRD_ST_ALW_EDITS11 := nvl(p_prefs(i).attribute11,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_APRVR_ENBLE_OVRD') then
   if(G_TC_W_APRVR_ENBLE_OVRD1 ='null') then
   G_TC_W_APRVR_ENBLE_OVRD1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_APRVR_DFLT_OVRD') then
   if(G_TC_W_APRVR_DFLT_OVRD1 ='null') then
    G_TC_W_APRVR_DFLT_OVRD1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;
  if(p_prefs(i).preference_code='TC_W_RULES_EVALUATION') then
   if(G_TC_W_RULES_EVALUATION1 ='null') then
    G_TC_W_RULES_EVALUATION1 := nvl(p_prefs(i).attribute1,'null');
   end if;
  end if;

  i := p_prefs.next(i);

END LOOP;

END set_pref_globals;

FUNCTION fetch_context_name
           (p_context_code in FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE)
           return varchar2 is

l_context_name FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_NAME%TYPE :='UNSET';

begin

-- Perf Rep Fix - SQL ID:3170183
-- Added where clause application_id = 809

  select descriptive_flex_context_name into l_context_name
    from fnd_descr_flex_contexts_vl
   where descriptive_flexfield_name = 'OTC Information Types'
     and descriptive_flex_context_code = p_context_code
     and application_id = 809;

  return l_context_name;

end fetch_context_name;

FUNCTION no_values_left
           (p_string IN VARCHAR2
           ,p_index  IN NUMBER)
           RETURN BOOLEAN IS

BEGIN

IF INSTR(p_string,g_separator,1,(p_index+1)) >0 THEN
  RETURN FALSE;
ELSE
  RETURN TRUE;
END IF;

END no_values_left;

FUNCTION add_value_to_string
           (p_string IN VARCHAR2
           ,p_value  IN varchar2)
           RETURN VARCHAR2 IS
BEGIN

  IF p_value IS NULL OR p_value = ''
  THEN
    RETURN p_string||g_separator|| 'null';
  END IF;

  RETURN p_string||g_separator||p_value;

END add_value_to_string;

FUNCTION get_first
          (p_string IN VARCHAR2
          ) RETURN VARCHAR2 IS

BEGIN

RETURN SUBSTR(p_string,2,(INSTR(p_string,g_separator,1,2)-2));

END get_first;

FUNCTION get_value_from_string
           (p_string      IN VARCHAR2
           ,p_value_index IN NUMBER
           ) RETURN VARCHAR2 IS

l_value HXC_TIME_BUILDING_BLOCKS.COMMENT_TEXT%TYPE;
l_proc  VARCHAR2(30) := 'GET_VALUE_FROM_STRING';
BEGIN

IF (INSTR(p_string,g_separator,1,p_value_index+1) = 0) THEN
   --
   -- We need to send back the very last thing in the string, i.e.
   -- everything from the final g_separator.
   --
   l_value := SUBSTR(p_string,(INSTR(p_string,g_separator,1,p_value_index)+1));
ELSE


   l_value := SUBSTR(p_string
             ,(INSTR(p_string,g_separator,1,p_value_index)+1)
             ,((INSTR(p_string,g_separator,1,(p_value_index+1))-1)
              -INSTR(p_string,g_separator,1,p_value_index))
              );
END IF;

   IF l_value = 'null'
   THEN
     l_value := NULL;
   END IF;

RETURN l_value;

END get_value_from_string;

FUNCTION check_global_context
          (p_context_prefix in VARCHAR2) return boolean is

l_dummy VARCHAR2(10);

BEGIN

  select 'Y' into l_dummy
    from fnd_descr_flex_contexts
   where application_id = 809
     and descriptive_flexfield_name = 'OTC Information Types'
     and enabled_flag = 'Y'
     and descriptive_flex_context_code like p_context_prefix||'%GLOBAL%';

   return true;

EXCEPTION
  WHEN no_data_found then

   return false;

END;

FUNCTION return_projects_context
           (p_system_linkage in varchar2
           ,p_expenditure_type in varchar2) return varchar2 is

cursor c_reference_field is
  select d.default_context_field_name
    from fnd_descriptive_flexs d
        ,fnd_application a
        ,fnd_product_installations z
   where d.application_id = a.application_id
     and z.application_id = a.application_id
     and a.application_short_name = 'PA'
     and z.status = 'I'
     and d.descriptive_flexfield_name = 'PA_EXPENDITURE_ITEMS_DESC_FLEX';

l_reference_field FND_DESCRIPTIVE_FLEXS.DEFAULT_CONTEXT_FIELD_NAME%TYPE;
l_pa_context_code varchar2(100) := '';
l_pa_context_name FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_NAME%TYPE := '';

l_pa_desc_flex_info varchar2(240) := '';

BEGIN

open c_reference_field;
fetch c_reference_field into l_reference_field;

if c_reference_field%NOTFOUND then

  l_pa_desc_flex_info := '';

else

  if (l_reference_field = 'SYSTEM_LINKAGE_FUNCTION') then

    if (p_system_linkage <> 'NO_PROJECTS') then

      -- Construct the context in the OTL Information type

 --   l_pa_context_code := 'PAEXPITDFF - '||p_system_linkage;
/* If the length of the system linkage is greater than 17, say for Painting-Decorating,
then the context name is PAEXPITDFF - Painting-Decorating and corresponding code
PAEXPITDFFC - 1221233 is obtained by using the function get_paexpitdff_code
Else the  usual process is followed */

      l_pa_context_code :=
HXC_DEPOSIT_WRAPPER_UTILITIES.get_dupdff_code('PAEXPITDFF - ' || p_system_linkage);


      -- Get the corresponding context name

      l_pa_context_name := fetch_context_name(l_pa_context_code);

    end if;

  elsif (l_reference_field = 'EXPENDITURE_TYPE') then

    if (p_expenditure_type <> 'NO_PROJECTS') then

--      l_pa_context_code := 'PAEXPITDFF - '||p_expenditure_type;
      l_pa_context_code :=
 HXC_DEPOSIT_WRAPPER_UTILITIES.get_dupdff_code('PAEXPITDFF - ' || p_expenditure_type);

      l_pa_context_name := fetch_context_name(l_pa_context_code);

    end if;

  elsif ((l_reference_field = '') OR (l_reference_field is NULL)) then

    if (check_global_context('PAEXPITDFF')) then

      l_pa_context_code := 'PAEXPITDFF - GLOBAL';
      l_pa_context_name := 'PAEXPITDFF - GLOBAL';

    end if;

  end if;

  l_pa_desc_flex_info := l_pa_context_code || g_separator || l_pa_context_name;

end if;

close c_reference_field;

return l_pa_desc_flex_info;

END return_projects_context;

  Procedure find_pa_information_from_alias
     (p_alias_value_id          in            hxc_alias_values.alias_value_id%type,
      p_expenditure_type           out nocopy hxc_time_attributes.attribute3%type,
      p_system_linkage_function    out nocopy hxc_time_attributes.attribute5%type
      ) is

     cursor c_segments(p_value_id in hxc_alias_values.alias_value_id%type) is
       select atc.component_name,
              fdfcu.application_column_name
         from fnd_descr_flex_column_usages fdfcu,
              hxc_alias_type_components atc,
              hxc_alias_types aty,
              hxc_alias_definitions ad,
              hxc_alias_values av
        where av.alias_value_id = p_value_id
          and av.alias_definition_id = ad.alias_definition_id
          and ad.alias_type_id = aty.alias_type_id
          and aty.alias_type_id = atc.alias_type_id
          and atc.component_name in ('EXPENDITURE_TYPE','SYSTEM_LINKAGE_FUNCTION')
          and atc.component_name = fdfcu.end_user_column_name
          and fdfcu.application_id = 809
          and fdfcu.descriptive_flexfield_name = 'OTC Aliases'
          and fdfcu.descriptive_flex_context_code = aty.reference_object
          and aty.alias_type = 'OTL_ALT_DDF';

     cursor c_value_row(p_value_id in hxc_alias_values.alias_value_id%type) is
       select *
         from hxc_alias_values av
        where av.alias_value_id = p_value_id;

     l_alias_value_row c_value_row%rowtype;
     l_row_value hxc_alias_values.attribute1%type;

  Begin
     /*
       We do this in something of strange way to avaid dynamic SQL,
       and to avaid hard coding the context in the query to look
       up the values.  Perhaps the dynamic SQL would be better?
     */
     p_expenditure_type := null;
     p_system_linkage_function := null;

     open c_value_row(p_alias_value_id);
     fetch c_value_row into l_alias_value_row;
     if(c_value_row%found) then
        close c_value_row;
        for seg_rec in c_segments(p_alias_value_id) loop
           l_row_value := '';
           if(seg_rec.application_column_name='ATTRIBUTE1') then
              l_row_value := l_alias_value_row.attribute1;
           elsif(seg_rec.application_column_name='ATTRIBUTE2') then
              l_row_value := l_alias_value_row.attribute2;
           elsif(seg_rec.application_column_name='ATTRIBUTE3') then
              l_row_value := l_alias_value_row.attribute3;
           elsif(seg_rec.application_column_name='ATTRIBUTE4') then
              l_row_value := l_alias_value_row.attribute4;
           elsif(seg_rec.application_column_name='ATTRIBUTE5') then
              l_row_value := l_alias_value_row.attribute5;
           elsif(seg_rec.application_column_name='ATTRIBUTE6') then
              l_row_value := l_alias_value_row.attribute6;
           elsif(seg_rec.application_column_name='ATTRIBUTE7') then
              l_row_value := l_alias_value_row.attribute7;
           elsif(seg_rec.application_column_name='ATTRIBUTE8') then
              l_row_value := l_alias_value_row.attribute8;
           elsif(seg_rec.application_column_name='ATTRIBUTE9') then
              l_row_value := l_alias_value_row.attribute9;
           elsif(seg_rec.application_column_name='ATTRIBUTE10') then
              l_row_value := l_alias_value_row.attribute10;
           elsif(seg_rec.application_column_name='ATTRIBUTE11') then
              l_row_value := l_alias_value_row.attribute11;
           elsif(seg_rec.application_column_name='ATTRIBUTE12') then
              l_row_value := l_alias_value_row.attribute12;
           elsif(seg_rec.application_column_name='ATTRIBUTE13') then
              l_row_value := l_alias_value_row.attribute13;
           elsif(seg_rec.application_column_name='ATTRIBUTE14') then
              l_row_value := l_alias_value_row.attribute14;
           elsif(seg_rec.application_column_name='ATTRIBUTE15') then
              l_row_value := l_alias_value_row.attribute15;
           elsif(seg_rec.application_column_name='ATTRIBUTE16') then
              l_row_value := l_alias_value_row.attribute16;
           elsif(seg_rec.application_column_name='ATTRIBUTE17') then
              l_row_value := l_alias_value_row.attribute17;
           elsif(seg_rec.application_column_name='ATTRIBUTE18') then
              l_row_value := l_alias_value_row.attribute18;
           elsif(seg_rec.application_column_name='ATTRIBUTE19') then
              l_row_value := l_alias_value_row.attribute19;
           elsif(seg_rec.application_column_name='ATTRIBUTE20') then
              l_row_value := l_alias_value_row.attribute20;
           elsif(seg_rec.application_column_name='ATTRIBUTE21') then
              l_row_value := l_alias_value_row.attribute21;
           elsif(seg_rec.application_column_name='ATTRIBUTE22') then
              l_row_value := l_alias_value_row.attribute22;
           elsif(seg_rec.application_column_name='ATTRIBUTE23') then
              l_row_value := l_alias_value_row.attribute23;
           elsif(seg_rec.application_column_name='ATTRIBUTE24') then
              l_row_value := l_alias_value_row.attribute24;
           elsif(seg_rec.application_column_name='ATTRIBUTE25') then
              l_row_value := l_alias_value_row.attribute25;
           elsif(seg_rec.application_column_name='ATTRIBUTE26') then
              l_row_value := l_alias_value_row.attribute26;
           elsif(seg_rec.application_column_name='ATTRIBUTE27') then
              l_row_value := l_alias_value_row.attribute27;
           elsif(seg_rec.application_column_name='ATTRIBUTE28') then
              l_row_value := l_alias_value_row.attribute28;
           elsif(seg_rec.application_column_name='ATTRIBUTE29') then
              l_row_value := l_alias_value_row.attribute29;
           elsif(seg_rec.application_column_name='ATTRIBUTE30') then
              l_row_value := l_alias_value_row.attribute30;
           end if;
           if(seg_rec.component_name = 'EXPENDITURE_TYPE') then
              p_expenditure_type := l_row_value;
           elsif(seg_rec.component_name = 'SYSTEM_LINKAGE_FUNCTION') then
              p_system_linkage_function := l_row_value;
           end if;
        end loop;
     else
        close c_value_row;
     end if;

  End find_pa_information_from_alias;

PROCEDURE build_context_string
            (p_context_codes       in            varchar2
            ,p_system_linkage      in            varchar2
            ,p_expenditure_type    in            varchar2
            ,p_pa_alias_value_id   in            varchar2
            ,p_context_string         out nocopy varchar2
            ) is

l_index                   number := 1;
l_context_code            FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE;
l_context_name            FND_DESCR_FLEX_CONTEXTS_VL.DESCRIPTIVE_FLEX_CONTEXT_NAME%TYPE;
l_pa_info                 VARCHAR2(240) := '';
l_expenditure_type        HXC_TIME_ATTRIBUTES.ATTRIBUTE3%TYPE;
l_system_linkage_function HXC_TIME_ATTRIBUTES.ATTRIBUTE5%TYPE;

begin

p_context_string := '';

if(length(p_context_codes) > 1) then

 loop

  l_context_code := get_value_from_string(p_context_codes,l_index);
  l_context_name := fetch_context_name(get_value_from_string(p_context_codes,l_index));

  if (length(p_context_string)>0) then

    p_context_string := p_context_string || g_separator
                   || get_value_from_string(p_context_codes,l_index)
                   || g_separator
                   || fetch_context_name(get_value_from_string(p_context_codes,l_index));

  else

    p_context_string := p_context_string
                   || get_value_from_string(p_context_codes,l_index)
                   || g_separator
                   || fetch_context_name(get_value_from_string(p_context_codes,l_index));
  end if;


  exit when no_values_left(p_context_codes, l_index);

  l_index := l_index + 1;

 end loop;
end if;

if(p_pa_alias_value_id <> 'NO_PROJECTS') then
  Begin
     find_pa_information_from_alias
	(to_number(p_pa_alias_value_id)
	 ,l_expenditure_type
	 ,l_system_linkage_function
	 );
     -- Will apply for ELP layouts.
     if((l_expenditure_type is null) and (l_system_linkage_function is null)) then
       l_system_linkage_function := p_system_linkage;
       l_expenditure_type := p_expenditure_type;
     end if;
  Exception
     When Others then
	l_expenditure_type := '';
	l_system_linkage_function := '';
  End;
else
    -- Projects Layout.
   l_system_linkage_function := p_system_linkage;
   l_expenditure_type := p_expenditure_type;
end if;

l_pa_info := return_projects_context(l_system_linkage_function, l_expenditure_type);

if (length(l_pa_info) > 0) then

  if (length(p_context_string) > 0) then

    p_context_string := p_context_string || g_separator || l_pa_info;

  else

    p_context_string := l_pa_info;

  end if;

end if;

exception
  when NO_DATA_FOUND then

    FND_MESSAGE.set_name('HXC','HXC_INVALID_INFO_CONTEXT');
    FND_MESSAGE.set_token('CONTEXT',p_context_codes);


END build_context_string;


PROCEDURE get_person_information
            (p_resource_id in number
            ,p_date in date
            ,p_person_info in out nocopy varchar2) is

cursor c_person_info
        (p_person_id in number
        ,p_d in date) is
  select papf.full_name
        ,paa.assignment_number
        ,to_char(papf.original_date_of_hire,'YYYY/MM/DD')
        ,paa.assignment_id
    from per_all_people_f papf
        ,per_all_assignments_f paa
   where paa.person_id = papf.person_id
     and p_d between paa.effective_start_date and paa.effective_end_date
     and p_d between papf.effective_start_date and papf.effective_end_date
     and paa.primary_flag = 'Y'
     and paa.assignment_type = 'E'
     and papf.person_id = p_person_id;

cursor closest_asg_record
          (p_person_id in number
          ,p_d in date) is
  select assignment_number
        ,assignment_id
        ,effective_start_date
        ,min(abs(effective_start_date-p_d))
    from per_all_assignments_f
   where person_id = p_person_id
     and primary_flag = 'Y'
     and assignment_type = 'E'
 group by assignment_number, assignment_id, effective_start_date;

cursor closest_per_record
          (p_person_id in number
          ,p_d in date) is
  select full_name,to_char(original_date_of_hire,'YYYY/MM/DD')
    from per_all_people_f
   where person_id = p_person_id
     and effective_start_date <= p_d
     and effective_end_date >= p_d;


l_full_name PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
l_assignment_number PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE;
l_assignment_id PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
l_hire_date VARCHAR2(30);
l_asg_start_date DATE;
l_min NUMBER;

BEGIN

open c_person_info(p_resource_id,p_date);
fetch c_person_info into l_full_name, l_assignment_number, l_hire_date,l_assignment_id;

if (c_person_info%NOTFOUND) then

  -- ok, check for any person records, they might
  -- begin outside this timecard period start date

  open closest_asg_record(p_resource_id,p_date);
  fetch closest_asg_record into l_assignment_number, l_assignment_id, l_asg_start_date, l_min;

  if closest_asg_record%NOTFOUND then

    close c_person_info;
    close closest_asg_record;

    FND_MESSAGE.set_name('HXC','HXC_NO_PERSON_INFO');
    FND_MESSAGE.raise_error;

  end if;

  close closest_asg_record;

  -- Here we assume that to have an assignment, you MUST
  -- have a person record!

  open closest_per_record(p_resource_id, l_asg_start_date);
  fetch closest_per_record into l_full_name, l_hire_date;
  close closest_per_record;

end if;

close c_person_info;

p_person_info := p_person_info || l_full_name || g_pref_sep || l_assignment_number || g_pref_sep || l_hire_date || g_pref_sep || l_assignment_id;

end get_person_information;

PROCEDURE get_period_information
            (p_resource_id in number
            ,p_period_returns out nocopy varchar2) is

cursor c_period_info
        (p_recurring_period_id in HXC_RECURRING_PERIODS.RECURRING_PERIOD_ID%TYPE) is
  select rp.period_type
        ,rp.duration_in_days
        ,p.number_per_fiscal_year
        ,substr(fnd_date.date_to_canonical(rp.start_date),1,50) start_date
   from  hxc_recurring_periods rp
        ,per_time_period_types p
  where  p.period_type (+) = rp.period_type
    and  rp.recurring_period_id = p_recurring_period_id;

l_period_type PER_TIME_PERIOD_TYPES.period_type%TYPE;
l_duration_in_days HXC_RECURRING_PERIODS.DURATION_IN_DAYS%TYPE;
l_number_per_fiscal_year PER_TIME_PERIOD_TYPES.NUMBER_PER_FISCAL_YEAR%TYPE;
l_start_date VARCHAR2(50);
l_recurring_period_id HXC_RECURRING_PERIODS.RECURRING_PERIOD_ID%TYPE;

l_v_duration_in_days VARCHAR2(2000);
l_v_number_per_fiscal_year VARCHAR2(2000);
l_v_period_type VARCHAR2(2000);

BEGIN

-- First obtain the preference for the recurring period id

l_recurring_period_id := hxc_preference_evaluation.resource_preferences(p_resource_id,'TC_W_TCRD_PERIOD|1|');

open c_period_info(l_recurring_period_id);
fetch c_period_info into l_period_type, l_duration_in_days, l_number_per_fiscal_year, l_start_date;

l_v_duration_in_days := NVL(to_char(l_duration_in_days),'null');
l_v_number_per_fiscal_year := NVL(to_char(l_number_per_fiscal_year),'null');
l_v_period_type := NVL(l_period_type,'null');


if (c_period_info%NOTFOUND) then

   FND_MESSAGE.set_name('HXC','HXC_MISSING_PERIOD_PREF');
   FND_MESSAGE.raise_error;

end if;

close c_period_info;

p_period_returns := l_v_period_type || g_pref_sep || l_v_duration_in_days || g_pref_sep || l_v_number_per_fiscal_year || g_pref_sep || l_start_date;

END get_period_information;

PROCEDURE check_pref_dates_against_asg
            (p_resource_id in number
            ,p_start_date in out nocopy date
            ,p_end_date in out nocopy date
            ) IS

cursor c_start_date
       (p_person_id in NUMBER) is
    SELECT min(paa.EFFECTIVE_START_DATE)
      FROM PER_ALL_ASSIGNMENTS_F paa,
           per_assignment_status_types typ
     WHERE paa.PERSON_ID = p_person_id
       AND paa.ASSIGNMENT_TYPE = 'E'
       AND paa.PRIMARY_FLAG = 'Y'
       AND paa.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ('ACTIVE_ASSIGN','ACTIVE_CWK');

cursor c_end_date
       (p_person_id in NUMBER) is
    SELECT max(paa.EFFECTIVE_END_DATE)
      FROM PER_ALL_ASSIGNMENTS_F paa,
           per_assignment_status_types typ
     WHERE paa.PERSON_ID = p_person_id
       AND paa.ASSIGNMENT_TYPE = 'E'
       AND paa.PRIMARY_FLAG = 'Y'
       AND paa.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ('ACTIVE_ASSIGN','ACTIVE_CWK');


l_start_date DATE;
l_end_date DATE;

BEGIN

open c_start_date(p_resource_id);
fetch c_start_date into l_start_date;

if c_start_date%NOTFOUND then
   close c_start_date;
   FND_MESSAGE.set_name('HXC','HXC_NO_ACTIVE_ASG');
   FND_MESSAGE.raise_error;
end if;

close c_start_date;

open c_end_date(p_resource_id);
fetch c_end_date into l_end_date;

if c_end_date%NOTFOUND then
   close c_end_date;
   FND_MESSAGE.set_name('HXC','HXC_NO_ACTIVE_ASG');
   FND_MESSAGE.raise_error;
end if;

close c_end_date;

--added by jxtan
IF SYSDATE > l_end_date
THEN

  p_start_date := l_start_date;
  p_end_date := l_end_date;

  RETURN;
END IF;


if(p_start_date < l_start_date) then
  p_start_date := l_start_date;
end if;

if(p_end_date > l_end_date) then
  p_end_date := l_end_date;
end if;

END check_pref_dates_against_asg;

PROCEDURE get_preferences
           (p_resource_id in number
           ,p_preference_string in varchar2
           ,p_include_pp in varchar2
           ,p_preference_date in varchar2
           ,p_preference_end_date in varchar2
           ,p_timecard_id in number
           ,p_preference_returns out nocopy varchar2
           ) IS

l_pref_date DATE;
l_pref_end_date DATE := null;

cursor c_start_time(p_id in number) is
  select start_time,stop_time
    from hxc_time_building_blocks
   where time_building_block_id = p_id
     and date_to = hr_general.end_of_time;

l_pref_table HXC_PREFERENCE_EVALUATION.T_PREF_TABLE;

BEGIN

  if (instr(p_preference_date,'/') > 0) then
     l_pref_date := to_date(p_preference_date,'YYYY/MM/DD');
  elsif (p_timecard_id > 0) then
     open c_start_time(p_timecard_id);
     fetch c_start_time into l_pref_date, l_pref_end_date;
     close c_start_time;
  else
     l_pref_date := sysdate;
  end if;

  if(l_pref_end_date is null) then

    if (instr(p_preference_end_date,'/') > 0) then
       l_pref_end_date := to_date(p_preference_end_date,'YYYY/MM/DD');
    else
       l_pref_end_date := sysdate;
    end if;

  end if;


  if (p_include_pp = 'Y') then

    get_period_information(p_resource_id, p_preference_returns);

    p_preference_returns := p_preference_returns || g_pref_sep;

  end if;

-- call the preference package to get all the
-- preferences associated with a resource

-- check the dates, so that we only ask for the
-- preference information within the range of
-- an active assignment for the resource

   check_pref_dates_against_asg
     (p_resource_id => p_resource_id
     ,p_start_date => l_pref_date
     ,p_end_date => l_pref_end_date
     );

    hxc_preference_evaluation.resource_preferences
      (p_resource_id => p_resource_id
      ,p_start_evaluation_date => l_pref_date
      ,p_end_evaluation_date => l_pref_end_date
      ,p_pref_table => l_pref_table
      );

-- Ok, next set the global preference variables
-- in this package

  set_pref_globals(l_pref_table);

-- And splat them together!

  p_preference_returns := p_preference_returns || splat_preferences;

-- Now set the preferences appropriately

  if (p_include_pp = 'Y') then

    p_preference_returns := p_preference_returns || g_pref_sep;
    get_person_information(p_resource_id, l_pref_date, p_preference_returns);

  end if;

END get_preferences;


FUNCTION blocks_to_string
           (p_blocks IN hxc_self_service_time_deposit.timecard_info)
           RETURN VARCHAR2 IS

l_block_count  NUMBER := 0;
l_block_string VARCHAR2(32767) := '';
l_proc         VARCHAR2(30) := 'BLOCKS_TO_STRING';

BEGIN

l_block_count := p_blocks.first;

LOOP

  EXIT WHEN NOT p_blocks.exists(l_block_count);

  --
  -- OK, need to check to see if this is a real
  -- building block that we need to send to the recipient
  -- application.
  --

  IF(
     (
      (p_blocks(l_block_count).type = 'RANGE')
     AND
      (p_blocks(l_block_count).start_time IS NOT NULL)
     )
    OR
     (
      (p_blocks(l_block_count).type = 'MEASURE')
     AND
      (p_blocks(l_block_count).measure IS NOT null)
     )
    ) THEN

  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).time_building_block_id
                      );

  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).TYPE
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).MEASURE
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).UNIT_OF_MEASURE
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,FND_DATE.DATE_TO_CANONICAL(p_blocks(l_block_count).START_TIME)
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,FND_DATE.DATE_TO_CANONICAL(p_blocks(l_block_count).STOP_TIME)
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).PARENT_BUILDING_BLOCK_ID
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).PARENT_IS_NEW
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).SCOPE
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).OBJECT_VERSION_NUMBER
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).APPROVAL_STATUS
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).RESOURCE_ID
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).RESOURCE_TYPE
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).APPROVAL_STYLE_ID
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,FND_DATE.DATE_TO_CANONICAL(p_blocks(l_block_count).DATE_FROM)
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,FND_DATE.DATE_TO_CANONICAL(p_blocks(l_block_count).DATE_TO)
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).COMMENT_TEXT
                      );
  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).PARENT_BUILDING_BLOCK_OVN
                      );

  l_block_string := add_value_to_string
                      (l_block_string
                      ,p_blocks(l_block_count).NEW
                      );

  END IF;

  l_block_count := p_blocks.next(l_block_count);

END LOOP;

RETURN l_block_string;

END blocks_to_string;

FUNCTION string_to_blocks
           (p_block_string IN varchar2)
           RETURN hxc_self_service_time_deposit.timecard_info IS

l_blocks hxc_self_service_time_deposit.timecard_info;
l_blocks2 hxc_self_service_time_deposit.timecard_info;
l_block_count NUMBER :=1;
l_value_index NUMBER :=1;
l_proc        VARCHAR2(30) := 'STRING_TO_BLOCKS';

l_bad BOOLEAN :=FALSE;

l_count NUMBER;
l_position NUMBER;
l_result hxc_time_building_blocks.comment_text%TYPE;
l_block_table t_simple_table;

BEGIN

-- new build ...

l_position:=0;
l_block_count:=0;

string_to_table(g_separator,p_block_string,l_block_table);

for l_count in 0..l_block_table.count-1 loop

 l_result:=l_block_table(l_count);

  if(l_position=0) then
   l_blocks2(l_block_count).time_building_block_id := l_result;
  elsif(l_position=1) then
   l_blocks2(l_block_count).type := l_result;
  elsif(l_position=2) then
   l_blocks2(l_block_count).measure    := l_result;
  elsif(l_position=3) then
   l_blocks2(l_block_count).unit_of_measure   := l_result;
  elsif(l_position=4) then
   l_blocks2(l_block_count).start_time := FND_DATE.CANONICAL_TO_DATE(l_result);
  elsif(l_position=5) then
   l_blocks2(l_block_count).stop_time  := FND_DATE.CANONICAL_TO_DATE(l_result);
  elsif(l_position=6) then
   l_blocks2(l_block_count).parent_building_block_id   := l_result;
  elsif(l_position=7) then
   l_blocks2(l_block_count).parent_is_new   := l_result;
  elsif(l_position=8) then
   l_blocks2(l_block_count).scope   := l_result;
  elsif(l_position=9) then
   l_blocks2(l_block_count).object_version_number  := l_result;
  elsif(l_position=10) then
   l_blocks2(l_block_count).approval_status   := l_result;
  elsif(l_position=11) then
   l_blocks2(l_block_count).resource_id   := l_result;
  elsif(l_position=12) then
   l_blocks2(l_block_count).resource_type   := l_result;
  elsif(l_position=13) then
   l_blocks2(l_block_count).approval_style_id   := l_result;
  elsif(l_position=14) then
   l_blocks2(l_block_count).date_from   := FND_DATE.CANONICAL_TO_DATE(l_result);
  elsif(l_position=15) then
   l_blocks2(l_block_count).date_to   := FND_DATE.CANONICAL_TO_DATE(l_result);
  elsif(l_position=16) then
   l_blocks2(l_block_count).comment_text   := l_result;
  elsif(l_position=17) then
   l_blocks2(l_block_count).parent_building_block_ovn  := l_result;
  elsif(l_position=18) then
   l_blocks2(l_block_count).new   := l_result;
   l_position := -1;
   l_block_count := l_block_count+1;
  end if;

  l_position:=l_position+1;

end loop;

/*
l_block_count:=0;

LOOP

  EXIT WHEN no_values_left(p_block_string,l_value_index);

  IF l_value_index = 0 THEN

    l_blocks(l_block_count).time_building_block_id
             := get_first
                  (p_string => p_block_string);
    l_value_index := l_value_index +1;
  ELSE
    l_blocks(l_block_count).time_building_block_id
             := get_value_from_string
                  (p_string      => p_block_string
                  ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  END IF;

  l_blocks(l_block_count).TYPE
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_blocks(l_block_count).MEASURE
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_blocks(l_block_count).UNIT_OF_MEASURE
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).START_TIME
           := FND_DATE.CANONICAL_TO_DATE(
               get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index));
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).STOP_TIME
           := FND_DATE.CANONICAL_TO_DATE(
               get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index));
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).PARENT_BUILDING_BLOCK_ID
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).PARENT_IS_NEW
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).SCOPE
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).OBJECT_VERSION_NUMBER
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).APPROVAL_STATUS
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).RESOURCE_ID
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).RESOURCE_TYPE
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).APPROVAL_STYLE_ID
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).DATE_FROM
           := FND_DATE.CANONICAL_TO_DATE(
               get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index));
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).DATE_TO
           := FND_DATE.CANONICAL_TO_DATE(
               get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index));
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).COMMENT_TEXT
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_blocks(l_block_count).PARENT_BUILDING_BLOCK_OVN
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_blocks(l_block_count).NEW
           := get_value_from_string
                (p_string      => p_block_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_block_count := l_block_count+1;

END LOOP;

-- now do comparison

for i in 0..l_blocks2.count-1 LOOP

if(l_blocks(i).time_building_block_id<>l_blocks2(i).time_building_block_id) then l_bad:=TRUE; end if;
if(l_blocks(i).type<>l_blocks2(i).type) then l_bad:=TRUE; end if;

end loop;

if(l_bad=TRUE) then
    hr_utility.set_message(809,'HXC_S2B_DO_NOT_MATCH');
    hr_utility.raise_error;
end if;

*/
RETURN l_blocks2;

END string_to_blocks;

FUNCTION attributes_to_string
           (p_attributes IN hxc_self_service_time_deposit.app_attributes_info)
           RETURN VARCHAR2 IS

l_attribute_string VARCHAR2(32767);
l_attribute_count  NUMBER;

BEGIN

l_attribute_count := p_attributes.first;

LOOP

  EXIT WHEN NOT p_attributes.exists(l_attribute_count);

  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).time_attribute_id
                      );
  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).Building_Block_Id
                      );
  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).Attribute_Name
                      );
  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).Attribute_Value
                      );
  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).Bld_Blk_Info_Type
                      );
  l_attribute_string := add_value_to_string
                      (l_attribute_string
                      ,p_attributes(l_attribute_count).Category
                      );

  l_attribute_count := p_attributes.next(l_attribute_count);

END LOOP;

RETURN l_attribute_string;

END attributes_to_string;

FUNCTION string_to_attributes
           (p_attribute_string IN varchar2)
           RETURN hxc_self_service_time_deposit.app_attributes_info IS

l_attributes hxc_self_service_time_deposit.app_attributes_info;
l_attributes2 hxc_self_service_time_deposit.app_attributes_info;
l_value_index NUMBER :=1;
l_attribute_count NUMBER := 0;
l_bad BOOLEAN :=FALSE;

l_count NUMBER;
l_position NUMBER;
l_result hxc_time_building_blocks.comment_text%TYPE;
l_attr_table t_simple_table;

BEGIN

-- leave comparision build using get_value_from_string until tested further

l_position := 0;
l_attribute_count := 0;

string_to_table(g_separator,p_attribute_string,l_attr_table);

for l_count in 0..l_attr_table.count-1 loop

 l_result := l_attr_table(l_count);

  if(l_position=0) then
   l_attributes2(l_attribute_count).time_attribute_id := l_result;
  elsif(l_position=1) then
   l_attributes2(l_attribute_count).building_block_id := l_result;
  elsif(l_position=2) then
   l_attributes2(l_attribute_count).attribute_name    := l_result;
  elsif(l_position=3) then
   l_attributes2(l_attribute_count).attribute_value   := l_result;
  elsif(l_position=4) then
   l_attributes2(l_attribute_count).bld_blk_info_type := l_result;
  elsif(l_position=5) then
   l_attributes2(l_attribute_count).category          := l_result;
   l_position := -1;
   l_attribute_count := l_attribute_count+1;
  end if;

  l_position:=l_position+1;

end loop;

-- now do traditional build ...
/*
l_attribute_count:=0;
LOOP

  EXIT WHEN no_values_left(p_attribute_string,l_value_index);

  IF l_value_index = 0 THEN
    l_attributes(l_attribute_count).time_attribute_id
             := get_first
                  (p_string => p_attribute_string);
    l_value_index := l_value_index +1;
  ELSE
    l_attributes(l_attribute_count).time_attribute_id
             := get_value_from_string
                  (p_string      => p_attribute_string
                  ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  END IF;
  l_attributes(l_attribute_count).building_block_id
           := get_value_from_string
                (p_string      => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_attributes(l_attribute_count).Attribute_Name
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute_Value
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Bld_Blk_Info_Type
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Category
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_attribute_count := l_attribute_count +1;

END LOOP;

-- now do comparison

for i in 0..l_attributes2.count-1 LOOP

if(l_attributes(i).time_attribute_id<>l_attributes2(i).time_attribute_id) then l_bad:=TRUE; end if;
if(l_attributes(i).building_block_id<>l_attributes2(i).building_block_id) then l_bad:=TRUE; end if;
if(l_attributes(i).attribute_name<>l_attributes2(i).attribute_name) then l_bad:=TRUE; end if;
if(l_attributes(i).attribute_value<>l_attributes2(i).attribute_value) then l_bad:=TRUE; end if;
if(l_attributes(i).bld_blk_info_type<>l_attributes2(i).bld_blk_info_type) then l_bad:=TRUE; end if;
if(l_attributes(i).category<>l_attributes2(i).category) then l_bad:=TRUE; end if;

end loop;

if(l_bad=TRUE) then
    hr_utility.set_message(809,'HXC_S2A_DO_NOT_MATCH');
    hr_utility.raise_error;
end if;
*/
RETURN l_attributes2;

END string_to_attributes;

FUNCTION string_to_bld_blk_attributes
           (p_attribute_string IN varchar2)
           RETURN hxc_self_service_time_deposit.building_block_attribute_info IS

l_attributes hxc_self_service_time_deposit.building_block_attribute_info;
l_attributes2 hxc_self_service_time_deposit.building_block_attribute_info;
l_value_index NUMBER :=1;
l_attribute_count NUMBER := 0;




l_bad BOOLEAN :=FALSE;

l_count NUMBER;
l_position NUMBER;
l_result hxc_time_building_blocks.comment_text%TYPE;
l_attr_table t_simple_table;

BEGIN

-- new build ...
-- leave comparision build using get_value_from_string until tested further

l_position:=0;
l_attribute_count:=0;

string_to_table(g_separator,p_attribute_string,l_attr_table);

for l_count in 0..l_attr_table.count-1 loop

 l_result:=l_attr_table(l_count);

  if(l_position=0) then
   l_attributes2(l_attribute_count).time_attribute_id := l_result;
  elsif(l_position=1) then
   l_attributes2(l_attribute_count).building_block_id := l_result;
  elsif(l_position=2) then
   l_attributes2(l_attribute_count).Attribute_Category:= l_result;
  elsif(l_position=3) then
   l_attributes2(l_attribute_count).attribute1        := l_result;
  elsif(l_position=4) then
   l_attributes2(l_attribute_count).attribute2        := l_result;
  elsif(l_position=5) then
   l_attributes2(l_attribute_count).attribute3        := l_result;
  elsif(l_position=6) then
   l_attributes2(l_attribute_count).attribute4        := l_result;
  elsif(l_position=7) then
   l_attributes2(l_attribute_count).attribute5        := l_result;
  elsif(l_position=8) then
   l_attributes2(l_attribute_count).attribute6        := l_result;
  elsif(l_position=9) then
   l_attributes2(l_attribute_count).attribute7        := l_result;
  elsif(l_position=10) then
   l_attributes2(l_attribute_count).attribute8        := l_result;
  elsif(l_position=11) then
   l_attributes2(l_attribute_count).attribute9        := l_result;
  elsif(l_position=12) then
   l_attributes2(l_attribute_count).attribute10       := l_result;
  elsif(l_position=13) then
   l_attributes2(l_attribute_count).attribute11       := l_result;
  elsif(l_position=14) then
   l_attributes2(l_attribute_count).attribute12       := l_result;
  elsif(l_position=15) then
   l_attributes2(l_attribute_count).attribute13       := l_result;
  elsif(l_position=16) then
   l_attributes2(l_attribute_count).attribute14       := l_result;
  elsif(l_position=17) then
   l_attributes2(l_attribute_count).attribute15       := l_result;
  elsif(l_position=18) then
   l_attributes2(l_attribute_count).attribute16       := l_result;
  elsif(l_position=19) then
   l_attributes2(l_attribute_count).attribute17       := l_result;
  elsif(l_position=20) then
   l_attributes2(l_attribute_count).attribute18       := l_result;
  elsif(l_position=21) then
   l_attributes2(l_attribute_count).attribute19       := l_result;
  elsif(l_position=22) then
   l_attributes2(l_attribute_count).attribute20       := l_result;
  elsif(l_position=23) then
   l_attributes2(l_attribute_count).attribute21       := l_result;
  elsif(l_position=24) then
   l_attributes2(l_attribute_count).attribute22       := l_result;
  elsif(l_position=25) then
   l_attributes2(l_attribute_count).attribute23       := l_result;
  elsif(l_position=26) then
   l_attributes2(l_attribute_count).attribute24       := l_result;
  elsif(l_position=27) then
   l_attributes2(l_attribute_count).attribute25       := l_result;
  elsif(l_position=28) then
   l_attributes2(l_attribute_count).attribute26       := l_result;
  elsif(l_position=29) then
   l_attributes2(l_attribute_count).attribute27       := l_result;
  elsif(l_position=30) then
   l_attributes2(l_attribute_count).attribute28       := l_result;
  elsif(l_position=31) then
   l_attributes2(l_attribute_count).attribute29       := l_result;
  elsif(l_position=32) then
   l_attributes2(l_attribute_count).attribute30       := l_result;
  elsif(l_position=33) then
   l_attributes2(l_attribute_count).Bld_Blk_Info_Type_Id  := l_result;
  elsif(l_position=34) then
   l_attributes2(l_attribute_count).Object_Version_Number  := l_result;
  elsif(l_position=35) then
   l_attributes2(l_attribute_count).new               := l_result;
  elsif(l_position=36) then
   l_attributes2(l_attribute_count).changed           := l_result;
  elsif(l_position=37) then
   l_attributes2(l_attribute_count).bld_blk_info_type := l_result;
   l_position := -1;
   l_attribute_count := l_attribute_count+1;
  end if;

  l_position:=l_position+1;

end loop;


-- old build
/*

l_attribute_count:=0;

LOOP

  EXIT WHEN no_values_left(p_attribute_string,l_value_index);

  IF l_value_index = 0 THEN
    l_attributes(l_attribute_count).time_attribute_id
             := get_first
                  (p_string => p_attribute_string);
    l_value_index := l_value_index +1;
  ELSE
    l_attributes(l_attribute_count).time_attribute_id
             := get_value_from_string
                  (p_string      => p_attribute_string
                  ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  END IF;
  l_attributes(l_attribute_count).building_block_id
           := get_value_from_string
                (p_string      => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute_Category
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute1
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute2
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute3
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute4
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute5
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute6
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute7
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute8
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute9
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute10
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute11
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute12
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute13
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute14
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute15
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute16
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute17
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute18
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute19
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute20
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute21
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute22
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute23
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute24
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute25
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute26
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute27
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute28
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute29
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Attribute30
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Bld_Blk_Info_Type_Id
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Object_Version_Number
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).New
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_attributes(l_attribute_count).Changed
           := get_value_from_string
                (p_string => p_attribute_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_attribute_count := l_attribute_count +1;

END LOOP;

-- now do comparison

for i in 0..l_attributes2.count-1 LOOP

if(l_attributes(i).time_attribute_id<>l_attributes2(i).time_attribute_id) then l_bad:=TRUE; end if;
if(l_attributes(i).building_block_id<>l_attributes2(i).building_block_id) then l_bad:=TRUE; end if;
if(l_attributes(i).attribute_category<>l_attributes2(i).attribute_category) then l_bad:=TRUE; end if;

end loop;

if(l_bad=TRUE) then
    hr_utility.set_message(809,'HXC_S2BA_DO_NOT_MATCH');
    hr_utility.raise_error;
end if;
*/


RETURN l_attributes2;

END string_to_bld_blk_attributes;

FUNCTION messages_to_string
           (p_messages IN hxc_self_service_time_deposit.message_table)
           RETURN VARCHAR2 IS

l_message_string VARCHAR2(32767);
l_message_count  NUMBER;

BEGIN

l_message_count := p_messages.first;

LOOP

  EXIT WHEN NOT p_messages.exists(l_message_count);

  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).message_name
                        );

  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).MESSAGE_LEVEL
                        );
  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).MESSAGE_FIELD
                        );
  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).MESSAGE_TOKENS
                        );
  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).APPLICATION_SHORT_NAME
                        );
  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).TIME_BUILDING_BLOCK_ID
                        );
  l_message_string := add_value_to_string
                        (l_message_string
                        ,p_messages(l_message_count).TIME_ATTRIBUTE_ID
                        );
  l_message_count := p_messages.next(l_message_count);

END LOOP;

RETURN l_message_string;

END messages_to_string;

FUNCTION string_to_messages
           (p_message_string IN varchar2)
           RETURN hxc_self_service_time_deposit.message_table IS

l_messages hxc_self_service_time_deposit.message_table;
l_value_index NUMBER :=1;
l_message_count NUMBER := 0;

BEGIN

LOOP

  EXIT WHEN no_values_left(p_message_string,l_value_index);

  IF l_value_index = 0 THEN
    l_messages(l_message_count).message_name
             := get_first
                  (p_string => p_message_string);
    l_value_index := l_value_index +1;
  ELSE
    l_messages(l_message_count).message_name
             := get_value_from_string
                  (p_string      => p_message_string
                  ,p_value_index => l_value_index);
    l_value_index := l_value_index +1;
  END IF;
  l_messages(l_message_count).message_level
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_messages(l_message_count).message_field
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_messages(l_message_count).message_tokens
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_messages(l_message_count).application_short_name
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_messages(l_message_count).time_building_block_id
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;
  l_messages(l_message_count).time_attribute_id
           := get_value_from_string
                (p_string      => p_message_string
                ,p_value_index => l_value_index);
  l_value_index := l_value_index +1;

  l_message_count := l_message_count +1;

END LOOP;

RETURN l_messages;

END string_to_messages;

FUNCTION attributes_to_string(
  p_attributes IN hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN VARCHAR2
IS
  l_attribute_string VARCHAR2(32767) := '';
  l_attribute_count NUMBER;
BEGIN

  l_attribute_count := p_attributes.first;

  LOOP

    EXIT WHEN NOT p_attributes.exists(l_attribute_count);


    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).time_attribute_id
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).building_block_id
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute_category
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute1
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute2
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute3
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute4
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute5
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute6
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute7
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute8
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute9
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute10
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute11
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute12
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute13
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute14
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute15
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute16
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute17
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute18
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute19
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute20
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute21
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute22
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute23
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute24
                        );


    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute25
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute26
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute27
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute28
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute29
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).attribute30
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).bld_blk_info_type_id
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).object_version_number
                        );
    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).new
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).changed
                        );

    l_attribute_string := add_value_to_string
                        (l_attribute_string
                        ,p_attributes(l_attribute_count).bld_blk_info_type
                        );

    l_attribute_count := p_attributes.next(l_attribute_count);

  END LOOP;

  RETURN l_attribute_string;
END attributes_to_string;

-- simple utility to load a pl/sql table from a token separated string of the
-- form '|one|two|three|...'.  Table indexing starts at zero
-- Cases:
-- string='|': returns one null table entry
-- string='': returns zero tables entry
-- string='|a|bc' returns two table entries. table(0)='a'. table(1)='bc'

PROCEDURE STRING_TO_TABLE(p_separator  IN VARCHAR2,
                          p_string     IN VARCHAR2,
                          p_table     OUT NOCOPY t_simple_table)
is
l_value_index NUMBER :=1;

l_index_start NUMBER;
l_index_next NUMBER;
l_loop_count NUMBER;
l_result hxc_time_building_blocks.comment_text%TYPE;


begin

l_index_start:=INSTR(p_string,p_separator,1,1)+1;

if(l_index_start=1 OR l_index_start is null) then
  return;
end if;

l_loop_count:=0;

LOOP

  l_index_next := INSTR(p_string,p_separator,l_index_start,1);

  if(l_index_next=0) then
    if ( length(p_string)+1-l_index_start > 2000 )
    then
        l_result := SUBSTR(p_string,l_index_start,2000);
    else
        l_result := SUBSTR(p_string,l_index_start,length(p_string)+1-l_index_start);
    end if;
  else
    if ( l_index_next-l_index_start > 2000 )
    then
        l_result := SUBSTR(p_string,l_index_start,2000);
    else
        l_result := SUBSTR(p_string,l_index_start,l_index_next-l_index_start);
    end if;
  end if;

  IF l_result = 'null'
  THEN
    l_result := NULL;
  END IF;

  p_table(l_loop_count):=l_result;

  l_index_start:=l_index_next+1;
  l_loop_count:=l_loop_count+1;
  EXIT WHEN l_index_next = 0;

  if(l_loop_count>30000) then
    hr_utility.set_message(809,'HXC_LPS');
    hr_utility.raise_error;
  end if;


END LOOP;

end STRING_TO_TABLE;

-- procedure
--   audit_transaction
--
-- description
--   records details of a deposit transaction in HXC_DEP_TRANSACTIONS
--   records details of a retrieval transaction in HXC_TRANSACTIONS
-- parameters
--   p_effective_date          - the effective date of the transaction
--   p_transaction_type        - deposit type (DEPOSIT/RETRIEVAL)
--   p_transaction_process_id  - the id of the deposit process
--   p_overall_status          - overall deposit status
--   p_transaction_status      - table of transactions

procedure audit_transaction
  (p_effective_date         in date
  ,p_transaction_type       in varchar2
  ,p_transaction_process_id in number
  ,p_overall_status         in varchar2
  ,p_transaction_tab        in out nocopy t_transaction
  ) is

PRAGMA AUTONOMOUS_TRANSACTION;

cursor c_transaction_sequence is
  select hxc_transactions_s.nextval from dual;

cursor c_transaction_detail_sequence is
  select hxc_transaction_details_s.nextval from dual;

l_transaction_id        hxc_transactions.transaction_id%TYPE;
l_transaction_detail_id hxc_transaction_details.transaction_detail_id%TYPE;
l_tx_ind		BINARY_INTEGER;

begin
  open c_transaction_sequence;
  fetch c_transaction_sequence into l_transaction_id;
  close c_transaction_sequence;


  IF p_transaction_type = 'DEPOSIT' THEN
  	insert into hxc_dep_transactions
  	  (transaction_id
  	  ,transaction_date
  	  ,type
  	  ,transaction_process_id
  	  ,created_by
  	  ,creation_date
  	  ,last_updated_by
  	  ,last_update_date
  	  ,last_update_login
  	  ,status
  	) values
  	  (l_transaction_id
  	  ,p_effective_date
  	  ,p_transaction_type
  	  ,p_transaction_process_id
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,p_overall_status
  	);
  ELSE
  	insert into hxc_transactions
  	  (transaction_id
  	  ,transaction_date
  	  ,type
  	  ,transaction_process_id
  	  ,created_by
  	  ,creation_date
  	  ,last_updated_by
  	  ,last_update_date
  	  ,last_update_login
  	  ,status
  	) values
  	  (l_transaction_id
  	  ,p_effective_date
  	  ,p_transaction_type
  	  ,p_transaction_process_id
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,p_overall_status
  	);
  END IF;




l_tx_ind := p_transaction_tab.FIRST;

WHILE ( l_tx_ind IS NOT NULL )
LOOP

  open c_transaction_detail_sequence;
  fetch c_transaction_detail_sequence into l_transaction_detail_id;
  close c_transaction_detail_sequence;

  IF p_transaction_type = 'DEPOSIT' THEN
  	insert into hxc_dep_transaction_details
  	  (transaction_detail_id
  	  ,time_building_block_id
  	  ,transaction_id
  	  ,created_by
  	  ,creation_date
  	  ,last_updated_by
  	  ,last_update_date
  	  ,last_update_login
  	  ,time_building_block_ovn
  	  ,status
  	  ,exception_description
  	) values
  	  (l_transaction_detail_id
  	  ,p_transaction_tab(l_tx_ind).tbb_id
  	  ,l_transaction_id
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,p_transaction_tab(l_tx_ind).tbb_ovn
  	  ,p_transaction_tab(l_tx_ind).status
  	  ,p_transaction_tab(l_tx_ind).exception_desc
  	);
  ELSE
  	insert into hxc_transaction_details
  	  (transaction_detail_id
  	  ,time_building_block_id
  	  ,transaction_id
  	  ,created_by
  	  ,creation_date
  	  ,last_updated_by
  	  ,last_update_date
  	  ,last_update_login
  	  ,time_building_block_ovn
  	  ,status
  	  ,exception_description
  	) values
  	  (l_transaction_detail_id
  	  ,p_transaction_tab(l_tx_ind).tbb_id
  	  ,l_transaction_id
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,sysdate
  	  ,null
  	  ,p_transaction_tab(l_tx_ind).tbb_ovn
  	  ,p_transaction_tab(l_tx_ind).status
  	  ,p_transaction_tab(l_tx_ind).exception_desc
  	);
  END IF;

  p_transaction_tab(l_tx_ind).txd_id := l_transaction_detail_id;

  l_tx_ind := p_transaction_tab.NEXT(l_tx_ind);

END LOOP;

commit;

end audit_transaction;

----
-- Function returning a list of hours types and ids for use on the timecard
----

function timecard_hours_type_list(  p_resource_id         in varchar2,
                                    p_start_time          in varchar2,
                                    p_stop_time           in varchar2,
                                    p_alias_or_element_id in varchar2) return varchar2

is

TYPE t_hours_type_list_row is RECORD (
element_id     NUMBER,
alias_value_id NUMBER,
display_value  hxc_alias_values.alias_value_name%TYPE
);

TYPE t_hours_type_list is table of
t_hours_type_list_row
index by binary_integer;

l_index           NUMBER;
l_hrs_typ_index   NUMBER;
l_loop_count      NUMBER;
l_hours_type_list t_hours_type_list;
l_aliases         hxc_alias_utility.t_alias_def_item;
l_id_string       VARCHAR2(30); -- this is used to store NUMBER(15)
l_ht_list_string  VARCHAR2(32000);
l_resource_id     NUMBER;
l_start_time      DATE;
l_stop_time       DATE;
l_time_diff number := 0;
-- Adding v115.53 Fix for Bug. 3161167
-- Adding new variables used for Insertion Sorting implementation.
i 		 NUMBER;
j 		 NUMBER;
l_hours_type_list_ins_alg t_hours_type_list;
l_display_value_ins_alg hxc_alias_values.alias_value_name%TYPE;


cursor csr_hours_type (p_alias_definition_id number,
                       p_start_date date,
                       p_end_date date,
                       p_person_id number)
is
select   havt.alias_value_name         Display_Value,
         hav.attribute1                element_id,
         hav.alias_value_id            alias_value_id
from     hxc_alias_values              hav,
         hxc_alias_values_tl          havt,
         hxc_alias_definitions         had
where
--hav.attribute_category='PAYROLL_ELEMENTS'
  hav.enabled_flag='Y'
  and had.alias_definition_id = hav.alias_definition_id
  and had.alias_definition_id = p_alias_definition_id
  and havt.language = USERENV('LANG')
  and havt.alias_value_id = hav.alias_value_id
  and hav.date_from <= p_end_date
  and nvl(hav.date_to,hr_general.end_of_time) >=p_start_date
and exists (
         select 'x'
from     PAY_ELEMENT_TYPES_F  ELEMENT,
         PAY_ELEMENT_CLASSIFICATIONS CLASSIFICATION,
         BEN_BENEFIT_CLASSIFICATIONS BENEFIT,
         PAY_ELEMENT_LINKS_F  LINK,
         PER_ALL_ASSIGNMENTS_F  ASGT,
         PER_PERIODS_OF_SERVICE  SERVICE_PERIOD
WHERE
  asgt.person_id = p_person_id and
  to_number(hav.attribute1) = ELEMENT.element_type_id
  AND ELEMENT.EFFECTIVE_START_DATE <= p_end_date
  AND ELEMENT.EFFECTIVE_END_DATE >= p_start_date
  AND ASGT.BUSINESS_GROUP_ID = LINK.BUSINESS_GROUP_ID
  AND  ELEMENT.ELEMENT_TYPE_ID = LINK.ELEMENT_TYPE_ID
  AND ELEMENT.BENEFIT_CLASSIFICATION_ID = BENEFIT.BENEFIT_CLASSIFICATION_ID (+)
  AND ELEMENT.CLASSIFICATION_ID = CLASSIFICATION.CLASSIFICATION_ID
  AND SERVICE_PERIOD.PERIOD_OF_SERVICE_ID = ASGT.PERIOD_OF_SERVICE_ID
  AND ASGT.EFFECTIVE_START_DATE  <= p_end_date
  AND ASGT.EFFECTIVE_END_DATE  >= p_start_date
  AND LINK.EFFECTIVE_START_DATE  <= p_end_date
  AND LINK.EFFECTIVE_END_DATE >= p_start_date
  AND ELEMENT.INDIRECT_ONLY_FLAG = 'N'
  AND UPPER (ELEMENT.ELEMENT_NAME) <> 'VERTEX'
  AND not exists
      (select 1
         from HR_ORGANIZATION_INFORMATION HOI,
              PAY_LEGISLATION_RULES PLR
        WHERE  plr.rule_type in
             ('ADVANCE','ADVANCE_INDICATOR','ADV_DEDUCTION',
              'PAY_ADVANCE_INDICATOR','ADV_CLEARUP','DEFER_PAY')
          AND   plr.rule_mode = to_char(element.element_type_id)
          AND  plr.legislation_code = hoi.org_information9
          AND   HOI.ORGANIZATION_ID =  ASGT.ORGANIZATION_ID
      )
AND ELEMENT.CLOSED_FOR_ENTRY_FLAG = 'N'
 AND ELEMENT.ADJUSTMENT_ONLY_FLAG = 'N'
 AND ((LINK.PAYROLL_ID IS NOT NULL AND LINK.PAYROLL_ID = ASGT.PAYROLL_ID)
      OR (LINK.LINK_TO_ALL_PAYROLLS_FLAG = 'Y' AND ASGT.PAYROLL_ID IS NOT NULL)
  OR (LINK.PAYROLL_ID IS NULL AND LINK.LINK_TO_ALL_PAYROLLS_FLAG = 'N'))
 AND  (LINK.ORGANIZATION_ID = ASGT.ORGANIZATION_ID OR LINK.ORGANIZATION_ID IS NULL)
 AND  (LINK.POSITION_ID = ASGT.POSITION_ID OR LINK.POSITION_ID IS NULL)
 AND  (LINK.JOB_ID = ASGT.JOB_ID OR LINK.JOB_ID IS NULL)
 AND  (LINK.GRADE_ID = ASGT.GRADE_ID OR LINK.GRADE_ID IS NULL)
 AND  (LINK.LOCATION_ID = ASGT.LOCATION_ID OR LINK.LOCATION_ID IS NULL)
 AND  (LINK.PAY_BASIS_ID = ASGT.PAY_BASIS_ID OR LINK.PAY_BASIS_ID IS NULL)
 AND  (LINK.EMPLOYMENT_CATEGORY = ASGT.EMPLOYMENT_CATEGORY OR
 LINK.EMPLOYMENT_CATEGORY IS NULL)
 AND  (LINK.PEOPLE_GROUP_ID IS NULL
  OR EXISTS (
   SELECT 1 FROM PAY_ASSIGNMENT_LINK_USAGES_F USAGE
   WHERE USAGE.ASSIGNMENT_ID = ASGT.ASSIGNMENT_ID
   AND USAGE.ELEMENT_LINK_ID = LINK.ELEMENT_LINK_ID
   AND (USAGE.EFFECTIVE_START_DATE  <= p_end_date
    AND USAGE.EFFECTIVE_END_DATE >= p_start_date)))
 AND  (ELEMENT.PROCESSING_TYPE = 'R' OR ASGT.PAYROLL_ID IS NOT NULL)
 AND (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NULL
  OR (SERVICE_PERIOD.ACTUAL_TERMINATION_DATE IS NOT NULL
  AND p_start_date <= DECODE(ELEMENT.POST_TERMINATION_RULE,
     'L', NVL(SERVICE_PERIOD.LAST_STANDARD_PROCESS_DATE,hr_general.end_of_time),
     'F', NVL(SERVICE_PERIOD.FINAL_PROCESS_DATE,
      hr_general.end_of_time),
     SERVICE_PERIOD.ACTUAL_TERMINATION_DATE))))
     ORDER BY Display_Value;


BEGIN

g_debug:=hr_utility.debug_enabled;
l_time_diff := 24*60*(sysdate - g_ht_time);

IF g_debug THEN
  hr_utility.trace(' In HXC_DEPOSIT_WRAPPER_UTILITIES.TIMECARD_HOURS_TYPE_LIST procedure');

  hr_utility.trace(' ****************Initial Information************************ ');

  hr_utility.trace(' ****************Start of Local values************************ ');
  hr_utility.trace(' p_resource_id 	   ::'||p_resource_id);
  hr_utility.trace(' p_start_time          ::'||p_start_time);
  hr_utility.trace(' p_stop_time           ::'||p_stop_time);
  hr_utility.trace(' p_alias_or_element_id ::'||p_alias_or_element_id);
  hr_utility.trace(' fnd_global.resp_id	   ::'||fnd_global.resp_id);
  hr_utility.trace(' ****************End of Local values************************ ');

  hr_utility.trace(' ****************Start of Global values************************ ');
  hr_utility.trace(' g_ht_resource_id 	       ::'||g_ht_resource_id);
  hr_utility.trace(' g_ht_start_time           ::'||g_ht_start_time);
  hr_utility.trace(' g_ht_stop_time            ::'||g_ht_stop_time);
  hr_utility.trace(' g_ht_alias_or_element_id  ::'||g_ht_alias_or_element_id);
  hr_utility.trace(' g_ht_resp_id	       ::'||g_ht_resp_id);
  hr_utility.trace(' ****************End of Global values************************ ');

  hr_utility.trace(' sysdate	   	   ::'||sysdate);
  hr_utility.trace(' g_ht_time	   	   ::'||g_ht_time);
  hr_utility.trace(' l_time_diff	   ::'||l_time_diff);

  hr_utility.trace(' ****************End of Initial Information************************ ');
END IF;

-- check to see if we can use a cached result

IF  l_time_diff < 5 then

if( g_ht_resource_id = p_resource_id AND
    g_ht_start_time  = p_start_time AND
    g_ht_stop_time   = p_stop_time  AND
    g_ht_alias_or_element_id = p_alias_or_element_id AND
    g_ht_resp_id = fnd_global.resp_id )
THEN

  IF g_debug THEN
    hr_utility.trace(' IF  l_time_diff < 5 then RETURN g_hours_type_list ::'||g_hours_type_list);
  END IF;

  return g_hours_type_list;

END IF;

END IF;  --- time diff testing

-- if not able to use cached result, need to generate. Store params so that we could cache next time

g_ht_resource_id := p_resource_id;
g_ht_start_time  := p_start_time;
g_ht_stop_time   := p_stop_time;
g_ht_alias_or_element_id := p_alias_or_element_id;
g_ht_resp_id := fnd_global.resp_id;
g_ht_time := sysdate;

IF g_debug THEN
    hr_utility.trace(' if not able to use cached result, need to generate. Store params so that we could cache next time');
    hr_utility.trace(' g_ht_resource_id 	   ::'||g_ht_resource_id);
    hr_utility.trace(' g_ht_start_time             ::'||g_ht_start_time);
    hr_utility.trace(' g_ht_stop_time              ::'||g_ht_stop_time);
    hr_utility.trace(' g_ht_alias_or_element_id    ::'||g_ht_alias_or_element_id);
    hr_utility.trace(' g_ht_resp_id	   	   ::'||g_ht_resp_id);
    hr_utility.trace(' g_ht_time	   	   ::'||g_ht_time);
    hr_utility.trace(' end of caced items.');
END IF;


-- convert params
l_resource_id := p_resource_id;
--l_start_time  := FND_DATE.CANONICAL_TO_DATE(p_start_time);
--l_stop_time   := FND_DATE.CANONICAL_TO_DATE(p_stop_time);

IF g_debug THEN
  hr_utility.trace(' Get list of valid aliases for this period.');
END IF;

-- get list of valid aliases for this period

IF  (p_alias_or_element_id = 'ALIAS'
  OR p_alias_or_element_id = 'ELEMENT') THEN

    l_aliases   := HXC_ALIAS_UTILITY.get_list_alias_id(p_alias_type => 'PAYROLL_ELEMENTS'
                                                 ,p_start_time => p_start_time
                                                 ,p_stop_time  => p_stop_time
                                                 ,p_resource_id => l_resource_id );

ELSE


   l_aliases   := HXC_ALIAS_UTILITY.get_list_alias_id(p_alias_type => p_alias_or_element_id
                                                 ,p_start_time => p_start_time
                                                 ,p_stop_time  => p_stop_time
                                                 ,p_resource_id => l_resource_id );

--if g_debug then
	--hr_utility.trace('p_alias_or_element_id '||p_alias_or_element_id);
--end if;

END IF;

IF g_debug THEN

 l_index := l_aliases.FIRST;
  LOOP
  EXIT WHEN NOT l_aliases.exists(l_index);

  hr_utility.trace(' RESOURCE_ID 		: '||l_aliases(l_index).RESOURCE_ID);
  hr_utility.trace(' PREF_START_DATE 		: '||l_aliases(l_index).PREF_START_DATE);
  hr_utility.trace(' PREF_END_DATE   		: '||l_aliases(l_index).PREF_END_DATE);
  hr_utility.trace(' ALIAS_DEFINITION_ID 	: '||l_aliases(l_index).ALIAS_DEFINITION_ID);
  hr_utility.trace(' ITEM_ATTRIBUTE_CATEGORY	: '||l_aliases(l_index).ITEM_ATTRIBUTE_CATEGORY);
  hr_utility.trace(' LAYOUT_ID			: '||l_aliases(l_index).LAYOUT_ID);
  hr_utility.trace(' ALIAS_LABEL 		: '||l_aliases(l_index).ALIAS_LABEL);

  l_index := l_aliases.NEXT(l_index);
  END LOOP;
END IF;

-- pull out TC_W_TCRD_ALIASES values

l_index:=l_aliases.FIRST;
l_start_time  := FND_DATE.CANONICAL_TO_DATE(p_start_time);
l_stop_time   := FND_DATE.CANONICAL_TO_DATE(p_stop_time);

-- first check to see that aliases have been setup for this person!!!
-- v115.23

IF ( l_index IS NOT NULL )
THEN

LOOP

-- execute cursor against each of these values. Shouldnt be too slow since
-- SQL cache should save us some time. Also, this will only execute more than
-- once if the alias changes mid period, which will not be the most common case

--dbms_output.put_line('Alais defn id:'||l_pref_table(l_index).attribute1);

IF g_debug THEN
  hr_utility.trace(' l_loop_count   ::'||l_loop_count);
END IF;

    FOR l_hours_type in csr_hours_type(p_person_id => l_resource_id,
                                       p_start_date    => l_aliases(l_index).pref_start_date,
                                       p_end_date      => l_aliases(l_index).pref_end_date,
                                       p_alias_definition_id => l_aliases(l_index).alias_definition_id) LOOP

-- Add values to list . Index list by alias_value_id thus removing duplicates automatically

--dbms_output.put_line('Element ID:'||pot_value.element_id);
--dbms_output.put_line('Alias Value id:'||pot_value.alias_value_id);
--dbms_output.put_line('Display_name:'||pot_value.display_value);

      l_hours_type_list(l_hours_type.alias_value_id).element_id := l_hours_type.element_id;
      l_hours_type_list(l_hours_type.alias_value_id).alias_value_id := l_hours_type.alias_value_id;
      l_hours_type_list(l_hours_type.alias_value_id).display_value := l_hours_type.display_value;

      IF g_debug THEN
      	  hr_utility.trace(' l_hours_type.alias_value_id   ::'||l_hours_type.alias_value_id);
          hr_utility.trace(' l_hours_type.element_id 	   ::'||l_hours_type.element_id);
          hr_utility.trace(' l_hours_type.alias_value_id   ::'||l_hours_type.alias_value_id);
          hr_utility.trace(' l_hours_type.display_value    ::'||l_hours_type.display_value);
      END IF;

    END LOOP;

  EXIT WHEN l_loop_count > 5000;

  l_loop_count := l_loop_count+1;
  l_index := l_aliases.NEXT(l_index);

  EXIT WHEN NOT l_aliases.EXISTS(l_index);

END LOOP;

-- Adding v115.56 fix for bug. 3264226
l_hours_type_list_ins_alg := l_hours_type_list;
l_hours_type_list.DELETE;

l_hrs_typ_index := 1;
l_index := null;
l_index := l_hours_type_list_ins_alg.first;
while l_index is not null
loop
      l_hours_type_list(l_hrs_typ_index).element_id := l_hours_type_list_ins_alg(l_index).element_id;
      l_hours_type_list(l_hrs_typ_index).alias_value_id := l_hours_type_list_ins_alg(l_index).alias_value_id;
      l_hours_type_list(l_hrs_typ_index).display_value := l_hours_type_list_ins_alg(l_index).display_value;

l_index := l_hours_type_list_ins_alg.NEXT(l_index);
l_hrs_typ_index := l_hrs_typ_index + 1;
end loop;
l_hours_type_list_ins_alg.DELETE;


-- Adding v115.53 Fix for Bug. 3161167
-- Adding new Insertion sort Algorithm
 IF ( l_hours_type_list.COUNT > 0) Then
  For i in l_hours_type_list.First+1..l_hours_type_list.LAST
     Loop
       l_display_value_ins_alg:=l_hours_type_list(i).display_value;
       l_hours_type_list_ins_alg(1) := l_hours_type_list(i);
        <<inner_loop>>
         For j in REVERSE l_hours_type_list.First.. (i-1)
            Loop
             If l_hours_type_list(j).display_value >= l_display_value_ins_alg then
                   l_hours_type_list(j+1):=l_hours_type_list(j);
                    l_hours_type_list(j):=l_hours_type_list_ins_alg(1);
                end if;
             end loop inner_loop;
    end loop;
End If;
-- End sorting logic

IF g_debug THEN

 l_index := l_hours_type_list.FIRST;
  LOOP
  EXIT WHEN NOT l_hours_type_list.exists(l_index);

  hr_utility.trace(' element_id 		: '||l_hours_type_list(l_index).element_id);
  hr_utility.trace(' alias_value_id 		: '||l_hours_type_list(l_index).alias_value_id);
  hr_utility.trace(' display_value   		: '||l_hours_type_list(l_index).display_value);

  l_index := l_hours_type_list.NEXT(l_index);
  END LOOP;
END IF;

-- now compile string according to callers choice

l_index:=l_hours_type_list.FIRST;

if (l_index is not null) then

LOOP

  IF    (p_alias_or_element_id = 'ALIAS') THEN
    l_id_string := l_hours_type_list(l_index).alias_value_id;
  ELSIF (p_alias_or_element_id = 'ELEMENT') THEN
    l_id_string := l_hours_type_list(l_index).element_id;
  ELSE
    l_id_string := l_hours_type_list(l_index).alias_value_id;
  END IF;

  l_ht_list_string :=   l_ht_list_string
                      ||l_hours_type_list(l_index).display_value
                      ||'|'
                      ||l_id_string
                      ||'|';

  EXIT WHEN l_loop_count > 5000;

  l_loop_count := l_loop_count+1;
  l_index := l_hours_type_list.NEXT(l_index);

  EXIT when not l_hours_type_list.EXISTS(l_index);

END LOOP;



g_hours_type_list := substr(l_ht_list_string,1,length(l_ht_list_string)-1);

IF g_debug THEN
  hr_utility.trace(' l_ht_list_string   ::'||l_ht_list_string);
  hr_utility.trace(' g_hours_type_list   ::'||g_hours_type_list);
  hr_utility.trace(' RETURN THE LIST');
END IF;

RETURN g_hours_type_list;

else

IF g_debug THEN
  hr_utility.trace('if (l_index is not null) then');
  hr_utility.trace(' RETURN null ');
END IF;

g_hours_type_list := null; -- added for bug 8814955

return g_hours_type_list;

end if;

ELSE -- l_index for alias list is null v115.23

IF g_debug THEN
  hr_utility.trace('IF ( l_index IS NOT NULL )');
  hr_utility.trace(' RETURN null ');
END IF;

g_hours_type_list := null; -- added for bug 8814955

return g_hours_type_list;

END IF;

END timecard_hours_type_list;


--
--
FUNCTION array_to_attributes(
  p_attribute_array IN HXC_ATTRIBUTE_TABLE_TYPE
)
RETURN hxc_self_service_time_deposit.building_block_attribute_info
IS
  l_array_index NUMBER;
  l_attribute_count NUMBER := 1;
  l_attributes hxc_self_service_time_deposit.building_block_attribute_info;
BEGIN
  l_array_index := p_attribute_array.first;
  LOOP
    EXIT WHEN NOT p_attribute_array.exists(l_array_index);

    l_attributes(l_attribute_count).time_attribute_id := p_attribute_array(l_array_index).time_attribute_id;
    l_attributes(l_attribute_count).building_block_id := p_attribute_array(l_array_index).building_block_id;
    l_attributes(l_attribute_count).Attribute_Category := p_attribute_array(l_array_index).Attribute_Category;
    l_attributes(l_attribute_count).attribute1        := p_attribute_array(l_array_index).attribute1;
    l_attributes(l_attribute_count).attribute2        := p_attribute_array(l_array_index).attribute2;
    l_attributes(l_attribute_count).attribute3        := p_attribute_array(l_array_index).attribute3;
    l_attributes(l_attribute_count).attribute4        := p_attribute_array(l_array_index).attribute4;
    l_attributes(l_attribute_count).attribute5        := p_attribute_array(l_array_index).attribute5;
    l_attributes(l_attribute_count).attribute6        := p_attribute_array(l_array_index).attribute6;
    l_attributes(l_attribute_count).attribute7        := p_attribute_array(l_array_index).attribute7;
    l_attributes(l_attribute_count).attribute8        := p_attribute_array(l_array_index).attribute8;
    l_attributes(l_attribute_count).attribute9        := p_attribute_array(l_array_index).attribute9;
    l_attributes(l_attribute_count).attribute10        := p_attribute_array(l_array_index).attribute10;
    l_attributes(l_attribute_count).attribute11       := p_attribute_array(l_array_index).attribute11;
    l_attributes(l_attribute_count).attribute12       := p_attribute_array(l_array_index).attribute12;
    l_attributes(l_attribute_count).attribute13       := p_attribute_array(l_array_index).attribute13;
    l_attributes(l_attribute_count).attribute14       := p_attribute_array(l_array_index).attribute14;
    l_attributes(l_attribute_count).attribute15       := p_attribute_array(l_array_index).attribute15;
    l_attributes(l_attribute_count).attribute16       := p_attribute_array(l_array_index).attribute16;
    l_attributes(l_attribute_count).attribute17       := p_attribute_array(l_array_index).attribute17;
    l_attributes(l_attribute_count).attribute18       := p_attribute_array(l_array_index).attribute18;
    l_attributes(l_attribute_count).attribute19       := p_attribute_array(l_array_index).attribute19;
    l_attributes(l_attribute_count).attribute20        := p_attribute_array(l_array_index).attribute20;
    l_attributes(l_attribute_count).attribute21        := p_attribute_array(l_array_index).attribute21;
    l_attributes(l_attribute_count).attribute22        := p_attribute_array(l_array_index).attribute22;
    l_attributes(l_attribute_count).attribute23        := p_attribute_array(l_array_index).attribute23;
    l_attributes(l_attribute_count).attribute24        := p_attribute_array(l_array_index).attribute24;
    l_attributes(l_attribute_count).attribute25        := p_attribute_array(l_array_index).attribute25;
    l_attributes(l_attribute_count).attribute26        := p_attribute_array(l_array_index).attribute26;
    l_attributes(l_attribute_count).attribute27        := p_attribute_array(l_array_index).attribute27;
    l_attributes(l_attribute_count).attribute28        := p_attribute_array(l_array_index).attribute28;
    l_attributes(l_attribute_count).attribute29        := p_attribute_array(l_array_index).attribute29;
    l_attributes(l_attribute_count).attribute30        := p_attribute_array(l_array_index).attribute30;
    l_attributes(l_attribute_count).Bld_Blk_Info_Type_Id  := p_attribute_array(l_array_index).Bld_Blk_Info_Type_Id;
    l_attributes(l_attribute_count).Object_Version_Number  := p_attribute_array(l_array_index).Object_Version_Number;
    l_attributes(l_attribute_count).new               := p_attribute_array(l_array_index).new;
    l_attributes(l_attribute_count).changed           := p_attribute_array(l_array_index).changed;
    l_attributes(l_attribute_count).bld_blk_info_type := p_attribute_array(l_array_index).bld_blk_info_type;

    l_attribute_count := l_attribute_count + 1;
    l_array_index := p_attribute_array.next(l_array_index);
  END LOOP;

  RETURN l_attributes;
END array_to_attributes;

FUNCTION attributes_to_array(
  p_attributes IN hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN HXC_ATTRIBUTE_TABLE_TYPE
IS
  l_attribute_array HXC_ATTRIBUTE_TABLE_TYPE;
  l_attribute       HXC_ATTRIBUTE_TYPE;
  l_array_index     NUMBER := 0;
  l_attribute_index NUMBER;
  l_proc            VARCHAR2(50);
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := 'attributes_to_array';
	hr_utility.set_location ( g_package||l_proc, 10);
  end if;
  --initialize attribute array
  l_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();

  l_attribute_index := p_attributes.first;
  LOOP
    EXIT WHEN NOT p_attributes.exists(l_attribute_index);

    l_array_index := l_array_index + 1;
    l_attribute_array.extend;

    l_attribute_array(l_array_index) :=
      HXC_ATTRIBUTE_TYPE(
        p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID
       ,p_attributes(l_attribute_index).BUILDING_BLOCK_ID
       ,p_attributes(l_attribute_index).ATTRIBUTE_CATEGORY
       ,p_attributes(l_attribute_index).ATTRIBUTE1
       ,p_attributes(l_attribute_index).ATTRIBUTE2
       ,p_attributes(l_attribute_index).ATTRIBUTE3
       ,p_attributes(l_attribute_index).ATTRIBUTE4
       ,p_attributes(l_attribute_index).ATTRIBUTE5
       ,p_attributes(l_attribute_index).ATTRIBUTE6
       ,p_attributes(l_attribute_index).ATTRIBUTE7
       ,p_attributes(l_attribute_index).ATTRIBUTE8
       ,p_attributes(l_attribute_index).ATTRIBUTE9
       ,p_attributes(l_attribute_index).ATTRIBUTE10
       ,p_attributes(l_attribute_index).ATTRIBUTE11
       ,p_attributes(l_attribute_index).ATTRIBUTE12
       ,p_attributes(l_attribute_index).ATTRIBUTE13
       ,p_attributes(l_attribute_index).ATTRIBUTE14
       ,p_attributes(l_attribute_index).ATTRIBUTE15
       ,p_attributes(l_attribute_index).ATTRIBUTE16
       ,p_attributes(l_attribute_index).ATTRIBUTE17
       ,p_attributes(l_attribute_index).ATTRIBUTE18
       ,p_attributes(l_attribute_index).ATTRIBUTE19
       ,p_attributes(l_attribute_index).ATTRIBUTE20
       ,p_attributes(l_attribute_index).ATTRIBUTE21
       ,p_attributes(l_attribute_index).ATTRIBUTE22
       ,p_attributes(l_attribute_index).ATTRIBUTE23
       ,p_attributes(l_attribute_index).ATTRIBUTE24
       ,p_attributes(l_attribute_index).ATTRIBUTE25
       ,p_attributes(l_attribute_index).ATTRIBUTE26
       ,p_attributes(l_attribute_index).ATTRIBUTE27
       ,p_attributes(l_attribute_index).ATTRIBUTE28
       ,p_attributes(l_attribute_index).ATTRIBUTE29
       ,p_attributes(l_attribute_index).ATTRIBUTE30
       ,p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID
       ,p_attributes(l_attribute_index).OBJECT_VERSION_NUMBER
       ,p_attributes(l_attribute_index).NEW
       ,p_attributes(l_attribute_index).CHANGED
       ,p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE
       ,'N'
       ,null
       );

    l_attribute_index := p_attributes.next(l_attribute_index);
  END LOOP;

  if g_debug then
	hr_utility.set_location ( g_package||l_proc, 20);
  end if;
  RETURN l_attribute_array;
END attributes_to_array;
--
-- Temporary function
--
FUNCTION array_to_blocks(
  p_block_array     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
)
RETURN hxc_self_service_time_deposit.timecard_info
IS
  l_array_index NUMBER;
  l_blocks	hxc_self_service_time_deposit.timecard_info;
BEGIN
  l_array_index := p_block_array.first;
  LOOP
    EXIT WHEN NOT p_block_array.exists(l_array_index);

       l_blocks(l_array_index).TIME_BUILDING_BLOCK_ID 	:=
       			p_block_array(l_array_index).TIME_BUILDING_BLOCK_ID;
       l_blocks(l_array_index).TYPE			:=
       			p_block_array(l_array_index).TYPE;
       l_blocks(l_array_index).MEASURE			:=
			p_block_array(l_array_index).MEASURE;
       l_blocks(l_array_index).UNIT_OF_MEASURE		:=
       			p_block_array(l_array_index).UNIT_OF_MEASURE;
       l_blocks(l_array_index).START_TIME		:=
       			fnd_date.canonical_to_date(p_block_array(l_array_index).START_TIME);
       l_blocks(l_array_index).STOP_TIME		:=
       			fnd_date.canonical_to_date(p_block_array(l_array_index).STOP_TIME);
       l_blocks(l_array_index).PARENT_BUILDING_BLOCK_ID	:=
       			p_block_array(l_array_index).PARENT_BUILDING_BLOCK_ID;
       l_blocks(l_array_index).PARENT_IS_NEW		:=
       			p_block_array(l_array_index).PARENT_IS_NEW;
       l_blocks(l_array_index).SCOPE			:=
       			p_block_array(l_array_index).SCOPE;
       l_blocks(l_array_index).OBJECT_VERSION_NUMBER	:=
       			p_block_array(l_array_index).OBJECT_VERSION_NUMBER;
       l_blocks(l_array_index).APPROVAL_STATUS		:=
       			p_block_array(l_array_index).APPROVAL_STATUS;
       l_blocks(l_array_index).RESOURCE_ID		:=
       			p_block_array(l_array_index).RESOURCE_ID;
       l_blocks(l_array_index).RESOURCE_TYPE		:=
       			p_block_array(l_array_index).RESOURCE_TYPE;
       l_blocks(l_array_index).APPROVAL_STYLE_ID	:=
       			p_block_array(l_array_index).APPROVAL_STYLE_ID;
       l_blocks(l_array_index).DATE_FROM		:=
       			fnd_date.canonical_to_date(p_block_array(l_array_index).DATE_FROM);
       l_blocks(l_array_index).DATE_TO			:=
       			fnd_date.canonical_to_date(p_block_array(l_array_index).DATE_TO);
       l_blocks(l_array_index).COMMENT_TEXT		:=
       			p_block_array(l_array_index).COMMENT_TEXT;
       l_blocks(l_array_index).PARENT_BUILDING_BLOCK_OVN:=
       			p_block_array(l_array_index).PARENT_BUILDING_BLOCK_OVN;
       l_blocks(l_array_index).NEW			:=
       			p_block_array(l_array_index).NEW;
       l_blocks(l_array_index).CHANGED			:=
       			p_block_array(l_array_index).CHANGED;

    l_array_index := p_block_array.next(l_array_index);
  END LOOP;

  RETURN l_blocks;
END array_to_blocks;

--
--
FUNCTION blocks_to_array(
  p_blocks IN hxc_self_service_time_deposit.timecard_info
)
RETURN HXC_BLOCK_TABLE_TYPE
IS
  l_block_array HXC_BLOCK_TABLE_TYPE;
  l_array_index NUMBER := 0;
  l_block_index NUMBER;
  l_proc        VARCHAR2(50);
--  l_block       HXC_BLOCK_TYPE;

BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := 'blocks_to_array';
	hr_utility.set_location ( g_package||l_proc, 10);
  end if;
  l_block_array := HXC_BLOCK_TABLE_TYPE();

  l_block_index := p_blocks.first;
  LOOP
    EXIT WHEN NOT p_blocks.exists(l_block_index);

    l_array_index := l_array_index + 1;
    l_block_array.extend;

    l_block_array(l_array_index) :=
      HXC_BLOCK_TYPE(
        p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID
       ,p_blocks(l_block_index).TYPE
       ,p_blocks(l_block_index).MEASURE
       ,p_blocks(l_block_index).UNIT_OF_MEASURE
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).START_TIME)
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).STOP_TIME)
       ,p_blocks(l_block_index).PARENT_BUILDING_BLOCK_ID
       ,p_blocks(l_block_index).PARENT_IS_NEW
       ,p_blocks(l_block_index).SCOPE
       ,p_blocks(l_block_index).OBJECT_VERSION_NUMBER
       ,p_blocks(l_block_index).APPROVAL_STATUS
       ,p_blocks(l_block_index).RESOURCE_ID
       ,p_blocks(l_block_index).RESOURCE_TYPE
       ,p_blocks(l_block_index).APPROVAL_STYLE_ID
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).DATE_FROM)
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).DATE_TO)
       ,p_blocks(l_block_index).COMMENT_TEXT
       ,p_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN
       ,p_blocks(l_block_index).NEW
       ,p_blocks(l_block_index).CHANGED
       ,'N'
       ,p_blocks(l_block_index).application_set_id
       ,p_blocks(l_block_index).TRANSLATION_DISPLAY_KEY --Bug 5565773
     );

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;

  if g_debug then
	hr_utility.set_location ( g_package||l_proc, 140);
  end if;
  RETURN l_block_array;
END blocks_to_array;

PROCEDURE maintain_errors (
  p_translated_bb_ids_tab hxc_self_service_time_deposit.translate_bb_ids_tab
, p_translated_ta_ids_tab hxc_self_service_time_deposit.translate_ta_ids_tab
, p_messages              IN  OUT NOCOPY hxc_self_service_time_deposit.message_table
, p_transactions          IN  OUT NOCOPY hxc_deposit_wrapper_utilities.t_transaction ) IS

l_msg_ind BINARY_INTEGER;
l_tbb_id  NUMBER;
l_ta_id   NUMBER;

l_proc varchar2(72);

cursor c_max_ovn
(p_tbb_id in number) is
 select max(object_version_number)
 from   hxc_time_building_blocks
 where  time_building_block_id = p_tbb_id;

cursor c_tx_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select transaction_id
 from  hxc_transaction_details
 where time_building_block_id = p_tbb_id
 and   object_version_number  = p_tbb_ovn;


TYPE r_tbb_vs_txd IS RECORD ( txd_id hxc_transaction_details.transaction_detail_id%TYPE );

TYPE t_tbb_vs_txd IS TABLE OF r_tbb_vs_txd INDEX BY BINARY_INTEGER;

t_tbb_vs_txds t_tbb_vs_txd;

l_tx_ind BINARY_INTEGER;

l_tx_id   NUMBER;
l_tbb_ovn NUMBER;

BEGIN
if g_debug then
	l_proc := g_package||'.maintain_errors';
	hr_utility.trace('transaction details are ');
end if;
/*
FOR x in p_transactions.FIRST .. p_transactions.LAST
LOOP
if g_debug then
	hr_utility.trace('txd tbb id is '||to_char(p_transactions(x).tbb_id));
	hr_utility.trace('txd txd id is '||to_char(p_transactions(x).txd_id));
end if;
END LOOP;

if g_debug then
	hr_utility.trace('');
	hr_utility.trace('messages are ');
end if;

FOR x in p_messages.FIRST .. p_messages.LAST
LOOP
	if g_debug then
		hr_utility.trace('message name is '||p_messages(x).message_name);
		hr_utility.trace('tbb id is '||to_char(p_messages(x).time_building_block_id));
		hr_utility.trace('tbb ovn is '||to_char(p_messages(x).time_building_block_ovn));
	end if;
END LOOP;
*/

if g_debug then
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

-- parse the transaction table to produce a mapping of time building blocks
-- to transaction details id- this will save traversing the table for every message

-- GPM v115.32

l_tx_ind := p_transactions.FIRST;

WHILE l_tx_ind IS NOT NULL
LOOP

	if g_debug then
		hr_utility.set_location('Processing '||l_proc, 20);
	end if;

	t_tbb_vs_txds(p_transactions(l_tx_ind).tbb_id).txd_id := p_transactions(l_tx_ind).txd_id;

	l_tx_ind := p_transactions.NEXT(l_tx_ind);

END LOOP;

if g_debug then
	hr_utility.set_location('Processing '||l_proc, 30);
end if;

-- if the timecard has just been inserted need to map dummy ids to new ids

	l_msg_ind := p_messages.FIRST;

	WHILE ( l_msg_ind IS NOT NULL )
	LOOP
		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 40);
		end if;
		-- assign to variables (makes it easier to read the following code)

		l_tbb_id := p_messages(l_msg_ind).time_building_block_id;
		l_ta_id  := p_messages(l_msg_ind).time_attribute_id;

		IF ( ( l_tbb_id IS NOT NULL ) AND ( p_translated_bb_ids_tab.COUNT <> 0 ) )
		THEN
			if g_debug then
				hr_utility.set_location('Processing '||l_proc, 50);
			end if;
			-- this may not be a new building block

			IF ( p_translated_bb_ids_tab.EXISTS(l_tbb_id) )
			THEN
				if g_debug then
					hr_utility.set_location('Processing '||l_proc, 60);
				end if;
				p_messages(l_msg_ind).time_building_block_id :=
				p_translated_bb_ids_tab(l_tbb_id).actual_bb_id;

				-- set the object version number back to 1
				-- remember it would have been set to ovn+1 in add_error_to_Table

				p_messages(l_msg_ind).time_building_block_ovn := 1;

			END IF;

		END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 70);
		end if;
		-- now the attribute

		IF ( ( l_ta_id IS NOT NULL ) AND ( p_translated_ta_ids_tab.COUNT <> 0 ) )
		THEN

			IF ( p_translated_ta_ids_tab.EXISTS(l_ta_id) )
			THEN

				p_messages(l_msg_ind).time_attribute_id :=
				p_translated_ta_ids_tab(l_ta_id).actual_ta_id;

			END IF;

		END IF;

		if g_debug then
			hr_utility.set_location('Processing '||l_proc, 75);
		end if;
		-- find the ovn of the tbb
		OPEN   c_max_ovn(p_messages(l_msg_ind).time_building_block_id);
		FETCH  c_max_ovn INTO l_tbb_ovn;
		CLOSE  c_max_ovn;

                --find the transaction_id from the tbb
                OPEN   c_tx_id(p_messages(l_msg_ind).time_building_block_id,l_tbb_ovn);
                FETCH  c_tx_id INTO l_tx_id;
                CLOSE  c_tx_id;

                IF (l_tx_id is null) THEN
                  l_tx_id := -1;
                END IF;

		INSERT INTO hxc_errors (
			error_id
		,	transaction_detail_id
		,	time_building_block_id
		,	time_building_block_ovn
		,	time_attribute_id
		,	time_attribute_ovn
		,	message_name
		,	message_level
		,	message_field
		,	message_tokens
		,	application_short_name
		,	object_version_number )
		VALUES (
			hxc_errors_s.nextval
		,	l_tx_id
		,	p_messages(l_msg_ind).time_building_block_id
		,	l_tbb_ovn
		,	p_messages(l_msg_ind).time_attribute_id
		,	p_messages(l_msg_ind).time_attribute_ovn
		,	p_messages(l_msg_ind).message_name
		,	p_messages(l_msg_ind).message_level
		,	p_messages(l_msg_ind).message_field
		,	p_messages(l_msg_ind).message_tokens
		,	p_messages(l_msg_ind).application_short_name
		,	1 );


		l_msg_ind := p_messages.NEXT(l_msg_ind);

	END LOOP;

	if g_debug then
		hr_utility.set_location('Leaving '||l_proc, 80);
	end if;
END maintain_errors;

/*This function obtains the PAEXPITDFF code from the PAEXPITDFF name.
First if the name is present in the g_code_name_tab  cache, then the
corresponding code is fetched, else the corresponding code is fetched
from the database table */
FUNCTION get_dupdff_code(p_dupdff_name IN VARCHAR2) return varchar2

   IS
      CURSOR get_code(p_name VARCHAR2,P_MESSAGE VARCHAR2)
      IS
          SELECT descriptive_flex_context_code
           FROM fnd_descr_flex_contexts_vl
          WHERE descriptive_flex_context_name = p_name
            AND descriptive_flexfield_name = 'OTC Information Types'
            AND application_id = 809
            AND  substrB(DESCRIPTIVE_FLEX_CONTEXT_CODE,0,instr(DESCRIPTIVE_FLEX_CONTEXT_CODE,'-')-2)
            =substrB(DESCRIPTIVE_FLEX_CONTEXT_name,0,instr(DESCRIPTIVE_FLEX_CONTEXT_name,'-')-2)||'C'
			AND SUBSTRB(DESCRIPTION,0, LENGTH(P_MESSAGE))=P_MESSAGE;

      l_index         NUMBER                                                   := 0;
      l_code          fnd_descr_flex_contexts_vl.descriptive_flex_context_code%TYPE;
      l_table_index   NUMBER;
      l_message varchar2(100);
   BEGIN
      l_code := NULL;
      l_index := g_code_name_tab.FIRST;

      LOOP
         EXIT WHEN NOT g_code_name_tab.EXISTS(l_index);
--         DBMS_OUTPUT.put_line(g_code_name_tab(l_index).dupdff_name);
--         DBMS_OUTPUT.put_line(g_code_name_tab(l_index).dupdff_code);

         IF g_code_name_tab(l_index).dupdff_name = p_dupdff_name
         THEN
            l_code := g_code_name_tab(l_index).dupdff_code;
            EXIT;
         END IF;

         l_index := g_code_name_tab.NEXT(l_index);
      END LOOP;

      IF l_code IS NULL
      THEN

      hr_utility.set_message(809,'HXC_DFF_SYSTEM_CONTEXT');
      l_message := hr_utility.get_message;
         OPEN get_code(p_dupdff_name,l_message);
         FETCH get_code INTO l_code;

         if l_code is null then
               CLOSE get_code;
         return(p_dupdff_name);

         else
         IF g_code_name_tab.count > 0
         THEN
            l_table_index := g_code_name_tab.count + 1;
         ELSE
            l_table_index := 1;
         END IF;

         g_code_name_tab(l_table_index).dupdff_code := l_code;
         g_code_name_tab(l_table_index).dupdff_name := p_dupdff_name;

         CLOSE get_code;
         end if;
      END IF;

      RETURN (l_code);
   END;

/*This function obtains the PAEXPITDFF Context Name from the PAEXPITDFF Context Code.
First if the Name is present in the g_code_name_tab  cache, then the corresponding
code is fetched, else the corresponding code is fetched from the database table */


FUNCTION get_dupdff_name (p_dupdff_code IN VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR get_name (p_code VARCHAR2, p_message VARCHAR2)
   IS
      SELECT descriptive_flex_context_name
        FROM fnd_descr_flex_contexts_vl
       WHERE descriptive_flex_context_code = p_code
         AND descriptive_flexfield_name = 'OTC Information Types'
         AND application_id = 809
         AND SUBSTRB (
                descriptive_flex_context_code,
                0,
                INSTR (descriptive_flex_context_code, '-') - 2
             ) =    SUBSTRB (
                       descriptive_flex_context_name,
                       0,
                       INSTR (descriptive_flex_context_name, '-') - 2
                    )
                 || 'C'
         AND SUBSTRB (description, 0, LENGTH (p_message)) = p_message;

   l_index     NUMBER                                                    := 0;
   l_name      fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;
   l_message   VARCHAR2 (100);
BEGIN
   l_name := NULL;

   l_index := TO_NUMBER (
                    SUBSTR (p_dupdff_code, INSTR (p_dupdff_code, '-') + 2)
                 );
      IF g_code_name_tab.EXISTS(L_INDEX) then
         l_name := g_code_name_tab (l_index).dupdff_name;
	   RETURN(l_name);

	ELSE

      hr_utility.set_message (809, 'HXC_DFF_SYSTEM_CONTEXT');
      l_message := hr_utility.GET_MESSAGE;
      OPEN get_name (p_dupdff_code, l_message);
      FETCH get_name INTO l_name;

      IF l_name IS NULL
      THEN
         CLOSE get_name;
         RETURN (p_dupdff_code);
      ELSE
         g_code_name_tab (l_index).dupdff_name := l_name;
         g_code_name_tab (l_index).dupdff_code := p_dupdff_code;
         CLOSE get_name;
      END IF;
      END IF;
   RETURN(l_name);
EXCEPTION
      WHEN OTHERS   THEN
RETURN (p_dupdff_code);
END;

function timecard_hours_type_list(  p_resource_id         in varchar2,
                                    p_start_time          in varchar2,
                                    p_stop_time           in varchar2,
                                    p_alias_or_element_id in varchar2,
				    p_aliases in VARCHAR2,
				    p_public_template in varchar2) return varchar2

is
-- Bug 7359347
-- Added the hint to avoid hard parsing
cursor cur_hours_type(p_alias_definition_id IN VARCHAR2) is
SELECT /*+ OPTIMIZER_FEATURES_ENABLE('9.2.0') */
  havt.alias_value_name         Display_Value,
  hav.attribute1  	       element_id,
  hav.alias_value_id            alias_value_id
FROM
  hxc_alias_values              hav,
  hxc_alias_values_tl          havt,
  hxc_alias_definitions         had,
  PAY_ELEMENT_TYPES_F  ELEMENT
WHERE
  hav.attribute1 = ELEMENT.element_type_id    and
  hav.enabled_flag='Y'    and
  had.alias_definition_id = hav.alias_definition_id    and
  havt.language = USERENV('LANG')    and
  havt.alias_value_id =hav.alias_value_id     and
  had.alias_definition_id = p_alias_definition_id    AND
  ELEMENT.EFFECTIVE_START_DATE <= sysdate    AND
  ELEMENT.EFFECTIVE_END_DATE >= sysdate;

l_hours_type_list varchar2(32000) :=null;
l_id_string varchar2(15) :=null;
l_start number;
l_index number;
l_alias varchar2(10);
l_aliases varchar2(1000);
begin


l_aliases :=p_aliases;
if p_public_template = 'Y' then

	IF ( p_aliases IS NOT NULL )
	THEN
	  l_start := 1;
	  l_index :=1;
	  while(l_index <> 0)
	  loop
		l_index := instr(l_aliases,',',l_start);
		l_alias :=  substr(l_aliases,l_start,(l_index-1));
		l_aliases := substr(l_aliases,(l_index+1));
		l_start := 1;

		if(l_alias is not null) then
			FOR l_hours_type in cur_hours_type(l_alias) LOOP

			IF    (p_alias_or_element_id = 'ALIAS') THEN
			    l_id_string := l_hours_type.alias_value_id;
			ELSIF (p_alias_or_element_id = 'ELEMENT') THEN
			    l_id_string := l_hours_type.element_id;
			END IF;
			l_hours_type_list :=   l_hours_type_list
			      ||l_hours_type.display_value
	                      ||'|'
		              ||l_id_string
			      ||'|';
		 END LOOP;
	   end if;
	   end loop;
	END IF;

ELSE

	l_hours_type_list := timecard_hours_type_list(p_resource_id,
				p_start_time,
				p_stop_time,
				p_alias_or_element_id);

END IF;
	return l_hours_type_list;
END timecard_hours_type_list;

-- Added a new procedure which would replace the resource_id in case of
-- duplication of public templates.

procedure replace_resource_id (p_blocks     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
				 p_resource_id IN hxc_time_building_blocks.resource_id%type) is
l_block_index number;
begin

if (p_blocks.count>0) then
l_block_index := p_blocks.first;
if(p_blocks(l_block_index).resource_id = p_resource_id) then
	return; -- If the resourceids are same, then we dont need to change.
end if;
LOOP
    EXIT WHEN NOT p_blocks.EXISTS(l_block_index);

    p_blocks(l_block_index).resource_id :=p_resource_id;

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;
end if;

end replace_resource_id;

END hxc_deposit_wrapper_utilities;


/
