--------------------------------------------------------
--  DDL for Package Body CSF_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_RESOURCE_PUB" AS
/* $Header: CSFPRESB.pls 120.20.12010000.35 2010/06/08 11:40:03 rkamasam ship $ */

  g_pkg_name        CONSTANT VARCHAR2(30) := 'CSF_RESOURCE_PUB';
  g_assign_doc_type CONSTANT VARCHAR2(2)  := 'SR';
  g_earth_radius    CONSTANT NUMBER       := 6378137;
  g_pi              CONSTANT NUMBER       := 2 * ACOS(0);
  g_res_add_prof            VARCHAR2(200);
  g_debug            VARCHAR2(1):= NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

  g_debug_level      NUMBER     := NVL(fnd_profile.value_specific('AFLOG_LEVEL'), fnd_log.level_event);


  TYPE qualifier_info_rec_type IS RECORD(
    qual_usg_id  jtf_seeded_qual_usgs_v.qual_usg_id%TYPE
  , label        jtf_seeded_qual_usgs_v.seeded_qual_name%TYPE
  );

  TYPE qualifier_info_tbl_type IS TABLE OF qualifier_info_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE varchar2_tbl_type IS TABLE OF VARCHAR2(32)
    INDEX BY BINARY_INTEGER;

  g_assign_errors            varchar2_tbl_type;
  g_all_qualifiers           qualifier_info_tbl_type;

  TYPE res_type_name_rec_type IS RECORD(
    resource_type_code jtf_objects_tl.object_code%TYPE
  , resource_type_name jtf_objects_tl.NAME%TYPE
  );

  TYPE res_type_name_tbl_type IS
    TABLE OF res_type_name_rec_type;

  g_res_type_name_tbl        res_type_name_tbl_type;

  /**
   * PLSQL Record Type to contain information about a Resource
   * along with his Address. Note that this couldnt be put
   * as an attribute as part of RESOURCE_REC_TYPE as Forms
   * cant use Records which have Complex Data Types as attributes
   */
  TYPE resource_cache_rec_type IS RECORD(
    resource_id       NUMBER
  , resource_type     jtf_objects_b.object_code%TYPE
  , resource_name     jtf_rs_resource_extns_tl.resource_name%TYPE
  , resource_number   jtf_rs_resource_extns.resource_number%TYPE
  , address           csf_resource_address_pvt.address_rec_type
  );

  /**
   * PLSQL Index By Table Type to contain information about many Resources
   * where each element is of type RESOURCE_CACHE_REC_TYPE.
   */
  TYPE resource_cache_tbl_type IS TABLE OF resource_cache_rec_type
    INDEX BY BINARY_INTEGER;

  g_res_info_cache           resource_cache_tbl_type;

  PROCEDURE debug(p_level NUMBER, p_module VARCHAR2, p_message VARCHAR2) IS
  BEGIN
    IF g_debug = 'Y' AND p_level >= g_debug_level THEN
      fnd_log.string(p_level, 'csf.plsql.CSF_RESOURCE_PUB.' || p_module, p_message);
    END IF;
  END debug;

  /**
   * Initializes the Table of possible Error Messages that can be
   * encountered during Resource Selection Process.
   * <br>
   * Index to the table G_ASSIGN_ERRORS represent the flags that have
   * been set to select the resources - namely Skills (S), Territories (T)
   * Installed Base (I) and Contracts (B). When a Flag is set to 'Y', the
   * corresponding bit is set to 1. Otherwise it is 0.
   * <br>
   * Examples:
   *     S T I C
   *     - - - -
   *     0 0 0 0     No selection criteria
   *     0 0 0 1     Only contracts
   *     0 0 1 0     Only installed base
   */
  PROCEDURE init_assign_errors IS
  BEGIN
    g_assign_errors(0)  := 'CSF_NO_RES_SEL_CRIT';                -- 0000
    g_assign_errors(1)  := 'CSF_NO_CONTRACT_RES';                -- 0001
    g_assign_errors(2)  := 'CSF_NO_IB_RES';                      -- 0010
    g_assign_errors(3)  := 'CSF_NO_CONTRACT_IB_RES';             -- 0011
    g_assign_errors(4)  := 'CSF_NO_TERR_RES';                    -- 0100
    g_assign_errors(5)  := 'CSF_TERR_CONTRACT_RES';              -- 0101
    g_assign_errors(6)  := 'CSF_NO_TERR_IB_RES';                 -- 0110
    g_assign_errors(8)  := 'CSF_NO_SKILLED_RES';                 -- 1000
    g_assign_errors(9)  := 'CSF_NO_CONTR_SKILL_RES';             -- 1001
    g_assign_errors(10) := 'CSF_NO_IB_SKILL_RES';                -- 1010
    g_assign_errors(11) := 'CSF_NO_CONTR_IB_SKILL_RES';          -- 1011
    g_assign_errors(12) := 'CSF_NO_TERR_SKILL_RES';              -- 1100
    g_assign_errors(13) := 'CSF_NO_TERR_CONTRACT_SKILL_RES';     -- 1101
    g_assign_errors(14) := 'CSF_NO_TERR_IB_SKILL_RES';           -- 1110
    g_assign_errors(15) := 'CSF_NO_TERR_CONTRACT_IB_RES';        -- 1111
  END init_assign_errors;

  /**
   * Gets the Task Information in the format as desired by JTF Assignment
   * Manager API.
   *
   * @param   p_task_id   Task Identifier
   * @returns Task Record (JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE).
   */
  FUNCTION get_srv_task_rec(p_task_id IN NUMBER)
    RETURN jtf_assign_pub.jtf_srv_task_rec_type IS
    l_rec                   jtf_assign_pub.jtf_srv_task_rec_type;
    l_contract_service_id   NUMBER;
    l_planned_start_date    date;
    -- Task, SR, Party and Address Information
    CURSOR c_rec IS
      SELECT tb.task_id task_id
           , ib.incident_id service_request_id
           , ib.customer_id party_id
           , lo.country
           , tb.address_id party_site_id
           , lo.city
           , lo.postal_code
           , lo.state
           , lo.county
           , pa.party_name comp_name_range
           , lo.province
           , pa.employees_total num_of_employees
           , tb.task_type_id
           , tb.task_status_id
           , tb.task_priority_id
           , ib.incident_type_id
           , ib.incident_severity_id
           , ib.incident_urgency_id
           , ib.problem_code
           , ib.incident_status_id
           , ib.platform_id
           , ib.site_id support_site_id
           , ib.customer_site_id
           , ib.sr_creation_channel
           , ib.inventory_item_id
           , ib.problem_code squal_char12
           , ib.comm_pref_code squal_char13
           , ib.platform_id squal_num12
           , ib.inv_platform_org_id squal_num13
           , ib.category_id squal_num14
           , ib.inventory_item_id squal_num15
           , ib.inv_organization_id squal_num16
           , ib.owner_group_id squal_num17
           , ib.language_id squal_num30
           , ib.contract_service_id
           , tb.planned_start_date
        FROM jtf_tasks_b tb
           , cs_incidents_all_b ib
           , cs_incidents_all_tl it
           , hz_locations lo
           , hz_parties pa
       WHERE tb.task_id = p_task_id
         AND tb.source_object_type_code = 'SR'
         AND tb.source_object_id = ib.incident_id
         AND tb.source_object_id = it.incident_id
         AND it.LANGUAGE = USERENV('lang')
         AND lo.location_id = csf_tasks_pub.get_task_location_id(tb.task_id, tb.address_id, tb.location_id)
         AND ib.customer_id = pa.party_id(+);

    -- Phone Area Code
    CURSOR c_contact_point(b_party_id NUMBER) IS
      SELECT phone_area_code
        FROM hz_contact_points
       WHERE owner_table_id = b_party_id
         AND owner_table_name = 'HZ_PARTIES'
         AND contact_point_type = 'PHONE'
         AND primary_flag = 'Y';

    -- Service Item ID and Organization ID
    CURSOR c_contract(b_contract_service_id NUMBER) IS
      SELECT TO_NUMBER(object1_id1) item_id
           , TO_NUMBER(object1_id2) org_id
        FROM okc_k_items
       WHERE cle_id = b_contract_service_id;

    -- Contact VIP code
    CURSOR c_class_code(b_party_id NUMBER) IS
      SELECT class_code
        FROM hz_code_assignments
       WHERE owner_table_name = 'HZ_PARTIES'
         AND owner_table_id = b_party_id;
  BEGIN
    OPEN c_rec;

    FETCH c_rec
     INTO l_rec.task_id
        , l_rec.service_request_id
        , l_rec.party_id
        , l_rec.country
        , l_rec.party_site_id
        , l_rec.city
        , l_rec.postal_code
        , l_rec.state
        , l_rec.county
        , l_rec.comp_name_range
        , l_rec.province
        , l_rec.num_of_employees
        , l_rec.task_type_id
        , l_rec.task_status_id
        , l_rec.task_priority_id
        , l_rec.incident_type_id
        , l_rec.incident_severity_id
        , l_rec.incident_urgency_id
        , l_rec.problem_code
        , l_rec.incident_status_id
        , l_rec.platform_id
        , l_rec.support_site_id
        , l_rec.customer_site_id
        , l_rec.sr_creation_channel
        , l_rec.inventory_item_id
        , l_rec.squal_char12
        , l_rec.squal_char13
        , l_rec.squal_num12
        , l_rec.squal_num13
        , l_rec.squal_num14
        , l_rec.squal_num15
        , l_rec.squal_num16
        , l_rec.squal_num17
        , l_rec.squal_num30
        , l_contract_service_id
        , l_planned_start_date;

    IF c_rec%FOUND THEN
      IF l_rec.party_id IS NOT NULL THEN
        -- Contact Phone Area Code
        OPEN c_contact_point(l_rec.party_id);
        FETCH c_contact_point INTO l_rec.area_code;
        CLOSE c_contact_point;

        -- contact VIP code
        OPEN c_class_code(l_rec.party_id);
        FETCH c_class_code INTO l_rec.squal_char11;
        CLOSE c_class_code;
      END IF;

      IF l_contract_service_id IS NOT NULL THEN
        -- Service item item_id and org_id
        OPEN c_contract(l_contract_service_id);
        FETCH c_contract INTO l_rec.squal_num18, l_rec.squal_num19;
        CLOSE c_contract;
      END IF;
    ELSE
      -- fill in only the task_id
      l_rec.task_id := p_task_id;
    END IF;

    CLOSE c_rec;

    if l_planned_start_date < sysdate
    then
      l_planned_start_date := sysdate;
    end if;

    l_rec.time_of_day := to_char(l_planned_start_date,'HH24:MI');
    l_rec.day_of_week := to_char(l_planned_start_date,'DAY');

    RETURN l_rec;
  END get_srv_task_rec;

  /**
   * Gets the Seeded Enabled Qualifier Names  (and if required Labels) and
   * populates the table G_ALL_QUALIFIERS.
   */
  PROCEDURE get_all_qualifiers IS
    k       PLS_INTEGER;
    CURSOR c_desc IS
      SELECT   qual_usg_id qual_usg_id
             , seeded_qual_name label
          FROM jty_all_enabled_attributes_v
         WHERE source_id = -1002
           AND qual_type_id IN(-1002, -1005, -1006)
      ORDER BY UPPER(seeded_qual_name);
    l_rec   qualifier_info_rec_type;
  BEGIN
    g_all_qualifiers.DELETE;
    OPEN c_desc;
    LOOP
      FETCH c_desc INTO l_rec;
      EXIT WHEN c_desc%NOTFOUND;
      g_all_qualifiers(c_desc%ROWCOUNT) := l_rec;
    END LOOP;
    CLOSE c_desc;
  END get_all_qualifiers;

  /**
   * Returns the Display Value for the Qualifier.
   *
   * If Tracing is not enabled, then it returns only Value concatenated
   * with the Associated Value. If Tracing is enabled, it uses the SQL
   * associated with the Qualifier and gets the Name / Description for
   * the Qualifier (ID to Name Conversion).
   *
   * @param   p_index            Index to the Global All Qualifiers Table
   * @param   p_value            Value for the Qualifier
   * @param   p_associated_value Associated Value for the Qualifier
   */
  FUNCTION get_display_value(
    p_index              IN   PLS_INTEGER
  , p_value              IN   VARCHAR2
  , p_associated_value   IN   VARCHAR2
  )
    RETURN VARCHAR2 IS
    l_tmp     VARCHAR2(4000);
    l_value   VARCHAR2(360);
  BEGIN
    -- for the default case use the provided values
    IF p_associated_value IS NULL THEN
      l_value := p_value;
    ELSE
      l_value := SUBSTR(p_value || '/' || p_associated_value, 1, 360);
    END IF;
    RETURN l_value;
  END get_display_value;

  PROCEDURE set_generic_planwindow (
    p_res_tbl IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_start                 DATE
  , p_end                   DATE
  ) IS
    i PLS_INTEGER;
  BEGIN
    i := p_res_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
      p_res_tbl(i).start_date := p_start;
      p_res_tbl(i).end_date   := p_end;
      i := p_res_tbl.NEXT(i);
    END LOOP;
  END set_generic_planwindow;

  /**
   * Adds the Qualifier identified by the Index to the global Task Qualifer Table with
   * the value taken from the given Task Record and only when the value is Not Null.
   * <br>
   * Uses a Hard Coded Mapping between JTF_SEEDED_QUAL_USGS_V.QUAL_USG_ID
   * and the fields in JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE.
   * <br>
   * Qualifiers of type -1211, -1212 and -1218 have been disabled and
   * therefore wont be set by this API.
   *
   * @param p_qualifiers Qualifier Table storing the Qualifiers
   * @param p_index      Index to the Global All Qualifiers Table
   * @param p_task_rec   Task Record containing the required Information
   */
  PROCEDURE add_qualifier(
    p_qualifier_tbl IN OUT NOCOPY resource_qualifier_tbl_type
  , p_index         IN            PLS_INTEGER
  , p_task_rec      IN            jtf_assign_pub.jtf_srv_task_rec_type
  ) IS
    l_value            VARCHAR2(360);
    l_associated_value VARCHAR2(360);
    i                  PLS_INTEGER;
  BEGIN
    IF g_all_qualifiers(p_index).qual_usg_id = -1037 THEN
      l_value := p_task_rec.party_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1038 THEN
      l_value := p_task_rec.country;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1039 THEN
      l_value := p_task_rec.party_site_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1040 THEN
      l_value := p_task_rec.city;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1041 THEN
      l_value := p_task_rec.postal_code;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1042 THEN
      l_value := p_task_rec.state;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1043 THEN
      l_value := p_task_rec.area_code;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1044 THEN
      l_value := p_task_rec.county;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1045 THEN
      l_value := p_task_rec.comp_name_range;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1046 THEN
      l_value := p_task_rec.province;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1047 THEN
      l_value := p_task_rec.num_of_employees;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1060 THEN
      l_value := p_task_rec.task_type_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1061 THEN
      l_value := p_task_rec.task_status_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1062 THEN
      l_value := p_task_rec.task_priority_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1048 THEN
      l_value := p_task_rec.incident_type_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1049 THEN
      l_value := p_task_rec.incident_severity_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1050 THEN
      l_value := p_task_rec.incident_urgency_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1051 THEN
      l_value := p_task_rec.problem_code;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1091 THEN
      l_value := p_task_rec.incident_status_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1092 THEN
      l_value := p_task_rec.platform_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1093 THEN
      l_value := p_task_rec.support_site_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1094 THEN
      l_value := p_task_rec.customer_site_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1095 THEN
      l_value := p_task_rec.sr_creation_channel;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1096 THEN
      l_value := p_task_rec.inventory_item_id;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1210 THEN
      l_value := p_task_rec.squal_num14;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1216 THEN
      l_value := p_task_rec.squal_num18;
      l_associated_value := p_task_rec.squal_num19;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1213 THEN
      l_value := p_task_rec.squal_num30;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1215 THEN
      l_value := p_task_rec.squal_char11;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1214 THEN
      l_value := p_task_rec.squal_char13;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1217 THEN
      l_value := p_task_rec.squal_num17;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1734 THEN
      l_value := p_task_Rec.day_of_week;
    ELSIF g_all_qualifiers(p_index).qual_usg_id = -1744 THEN
      l_value := p_task_Rec.time_of_day;
    END IF;

    IF l_value IS NOT NULL THEN
      i := p_qualifier_tbl.COUNT + 1;
      p_qualifier_tbl(i).qual_usg_id      := g_all_qualifiers(p_index).qual_usg_id;
      p_qualifier_tbl(i).label            := g_all_qualifiers(p_index).label;
      p_qualifier_tbl(i).use_flag         := 'Y';
      p_qualifier_tbl(i).value            := l_value;
      p_qualifier_tbl(i).associated_value := l_associated_value;
      p_qualifier_tbl(i).display_value    := get_display_value(p_index, l_value, l_associated_value);
    END IF;
  END add_qualifier;

  /**
   * Returns the Qualifier Table having the list of valid Qualifiers
   * based on the Task Information of the given Task ID.
   */
  FUNCTION get_res_qualifier_table(p_task_id NUMBER)
    RETURN resource_qualifier_tbl_type IS
    m               PLS_INTEGER;
    l_task_rec      jtf_assign_pub.jtf_srv_task_rec_type;
    l_qualifier_tbl resource_qualifier_tbl_type;
  BEGIN
    -- Fetch all the Enabled Qualifiers
    IF g_all_qualifiers.COUNT = 0 THEN
      get_all_qualifiers;
    END IF;

    -- Get the Task Information
    l_task_rec := get_srv_task_rec(p_task_id);

    -- Loop thru the Qualifiers and add the valid Qualifier alone to the Table
    m := g_all_qualifiers.FIRST;
    WHILE m IS NOT NULL LOOP
      add_qualifier(l_qualifier_tbl, m, l_task_rec);
      m := g_all_qualifiers.NEXT(m);
    END LOOP;

    RETURN l_qualifier_tbl;
  END get_res_qualifier_table;

  /**
   * Converts the given Qualifier Table to Assignment Manager API Record
   * type.
   * Assembles the selected Qualifiers for this Task from the Qualifier
   * Table in to a Record Type understandable by JTF Assignment Manager.
   * <br>
   * Uses a Hard Coded Mapping between JTF_SEEDED_QUAL_USGS_V.QUAL_USG_ID
   * and the fields in JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE.
   * <br>
   * The Task and SR Number must be set by the caller and wont be set by
   * this API. Moreover Qualifiers of type -1211, -1212 and -1218 have
   * been disabled and therefore wont be set by this API.
   *
   * @param p_table   Qualifier Table having the list of Task Qualifiers
   */
  FUNCTION get_qualified_task_rec(p_table resource_qualifier_tbl_type)
    RETURN jtf_assign_pub.jtf_srv_task_rec_type IS
    k         PLS_INTEGER;
    task_rec  jtf_assign_pub.jtf_srv_task_rec_type;
  BEGIN
    k := p_table.FIRST;
    WHILE k IS NOT NULL LOOP
      IF p_table(k).use_flag = 'Y' THEN
        IF p_table(k).qual_usg_id = -1037 THEN
          task_rec.party_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1038 THEN
          task_rec.country := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1039 THEN
          task_rec.party_site_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1040 THEN
          task_rec.city := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1041 THEN
          task_rec.postal_code := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1042 THEN
          task_rec.state := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1043 THEN
          task_rec.area_code := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1044 THEN
          task_rec.county := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1045 THEN
          task_rec.comp_name_range := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1046 THEN
          task_rec.province := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1047 THEN
          task_rec.num_of_employees := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1060 THEN
          task_rec.task_type_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1061 THEN
          task_rec.task_status_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1062 THEN
          task_rec.task_priority_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1048 THEN
          task_rec.incident_type_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1049 THEN
          task_rec.incident_severity_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1050 THEN
          task_rec.incident_urgency_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1051 THEN
          task_rec.problem_code := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1091 THEN
          task_rec.incident_status_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1092 THEN
          task_rec.platform_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1093 THEN
          task_rec.support_site_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1094 THEN
          task_rec.customer_site_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1095 THEN
          task_rec.sr_creation_channel := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1096 THEN
          task_rec.inventory_item_id := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1210 THEN
          task_rec.squal_num14 := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1217 THEN
          task_rec.squal_num17 := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1216 THEN
          task_rec.squal_num18 := p_table(k).VALUE;
          task_rec.squal_num19 := p_table(k).associated_value;
        ELSIF p_table(k).qual_usg_id = -1213 THEN
          task_rec.squal_num30 := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1215 THEN
          task_rec.squal_char11 := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1214 THEN
          task_rec.squal_char13 := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1734 THEN
          task_rec.DAY_OF_WEEK := p_table(k).VALUE;
        ELSIF p_table(k).qual_usg_id = -1744 THEN
          task_rec.TIME_OF_DAY := p_table(k).VALUE;
        END IF;
      END IF;
      k := p_table.NEXT(k);
    END LOOP;
    RETURN task_rec;
  END get_qualified_task_rec;

  /**
   * Intersect the Resource results found in two tables and returns a
   * Table having only those Resources found in both the Tables.
   *
   * The parameters P_START and P_END signify the Plan Window for which
   * Resources are desired. If either of the input tables doesnt have
   * the Plan Window stamped for any resource, these two dates will be used
   * in place of them. After this action, the most restrictive Plan Window
   * among the two windows is used as the Plan Window of the output table.
   * <br>
   * Side Effect of the API. Second Table may have entries deleted after
   * the operation.
   *
   * @param   p_res_1_tbl   Resource Table 1
   * @param   p_res_2_tbl   Resource Table 2
   * @param   p_start       Start Date of the Window
   * @param   p_end         End Date of the Window
   * @return  Common Resource Table (JTF_ASSIGN_PUB.ASSIGNRESOURCES_TBL_TYPE)
   */
  FUNCTION intersect_results(
    p_res_1_tbl   IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_res_2_tbl   IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_start                     DATE
  , p_end                       DATE
  ) RETURN jtf_assign_pub.assignresources_tbl_type IS
    i           PLS_INTEGER;
    j           PLS_INTEGER;
    k           PLS_INTEGER;
    l_res_tbl   jtf_assign_pub.assignresources_tbl_type;
  BEGIN
    k := 0;
    i := p_res_1_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
      j := p_res_2_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
        EXIT WHEN p_res_2_tbl(j).resource_id = p_res_1_tbl(i).resource_id
              AND p_res_2_tbl(j).resource_type = p_res_1_tbl(i).resource_type;
        j := p_res_2_tbl.NEXT(j);
      END LOOP;

      -- We have an intersection between first table and second. Add to the output table
      IF j IS NOT NULL THEN
        k := k + 1;
        l_res_tbl(k) := p_res_1_tbl(i);
        l_res_tbl(k).start_date := GREATEST( NVL(p_res_1_tbl(i).start_date, p_start)
                                           , NVL(p_res_2_tbl(j).start_date, p_start)
                                           );
        l_res_tbl(k).end_date   := LEAST( NVL(p_res_1_tbl(i).end_date, p_end)
                                        , NVL(p_res_2_tbl(j).end_date, p_end)
                                        );

        IF p_res_2_tbl(j).skill_level IS NOT NULL THEN
          l_res_tbl(k).skill_level := p_res_2_tbl(j).skill_level;
        END IF;

        IF p_res_2_tbl(j).TERR_ID IS NOT NULL AND p_res_2_tbl(j).TERR_ID <> -1 THEN
          l_res_tbl(k).TERR_ID := p_res_2_tbl(j).TERR_ID;
        END IF;

        IF p_res_2_tbl(j).TERR_RANK IS NOT NULL AND p_res_2_tbl(j).TERR_RANK <> -1 THEN
          l_res_tbl(k).TERR_RANK := p_res_2_tbl(j).TERR_RANK;
        END IF;

        p_res_2_tbl.DELETE(j); -- So that Table is smaller for other iterations.

      END IF;
      i := p_res_1_tbl.NEXT(i);
    END LOOP;
    RETURN l_res_tbl;
  END intersect_results;

  /**
   * Union the Resource results found in two tables and returns a
   * Table having all those Resources found in both the Tables.
   *
   * In case of duplicate rows, row from 'p_res_1_tbl' will override.
   *
   * Side Effect of the API. Second Table may have entries deleted after
   * the operation.
   *
   * @param   p_res_1_tbl   Resource Table 1
   * @param   p_res_2_tbl   Resource Table 2
   * @return  Common Resource Table (JTF_ASSIGN_PUB.ASSIGNRESOURCES_TBL_TYPE)
   */
  FUNCTION union_results(
    p_res_1_tbl   IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_res_2_tbl   IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  ) RETURN jtf_assign_pub.assignresources_tbl_type IS
    i           PLS_INTEGER;
    j           PLS_INTEGER;
    k           PLS_INTEGER;
    l_res_tbl   jtf_assign_pub.assignresources_tbl_type;
  BEGIN
    k := p_res_1_tbl.LAST;
    i := p_res_2_tbl.FIRST;

    IF p_res_1_tbl.COUNT > 0 AND p_res_2_tbl.COUNT < 1
    THEN
      RETURN p_res_1_tbl;
    END IF;

    IF p_res_2_tbl.COUNT > 0 AND p_res_1_tbl.COUNT < 1
    THEN
      RETURN p_res_2_tbl;
    END IF;

    IF p_res_2_tbl.COUNT = 0 AND p_res_1_tbl.COUNT = 0
    THEN
      RETURN l_res_tbl;
    END IF;

    WHILE i IS NOT NULL LOOP
      j := p_res_1_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
         EXIT WHEN p_res_2_tbl(i).resource_id = p_res_1_tbl(j).resource_id
              AND p_res_2_tbl(i).resource_type = p_res_1_tbl(j).resource_type;

        j := p_res_1_tbl.NEXT(j);
      END LOOP;

      IF j IS NULL THEN
        p_res_1_tbl(k+1) := p_res_2_tbl(i);
        k := p_res_1_tbl.LAST;
      END IF;


      i := p_res_2_tbl.NEXT(i);
    END LOOP;
    RETURN p_res_1_tbl;
  END union_results;


  /**
   * Returns the Skilled Resources for a Task overlapping the given
   * Plan Window.
   * <br>
   * This API will return the list of all Skilled Resources for the Task
   * with the activity date lying between the passed Plan Window. There
   * will be an individual plan window (Adapted) for each resource.
   * <br>
   * If Resource ID is passed, then the API returns only one record
   * corresponding to the passed Resource if he has the Skill Active
   * during the given Times as desired by the Task.
   * <br>
   * The API makes use of the profile CSF_SKILL_LEVEL_MATCH to determine
   * whether the Resource has a Skill Level comparable with the Task requirements
   * as dictated by the profile.
   * Usage of the Profile is as follows
   *   1 - EQUAL TO or SMALLER THAN
   *   2 - EQUAL TO                  --> (Default Value)
   *   3 - EQUAL TO or GREATER THAN
   * <br>
   * Note that the API is made a PROCEDURE from its initial version of being a
   * FUNCTION so that we can use the NOCOPY Compiler Directive and avoid the
   * expensive Table Copy Happening during each call.
   *
   * @param    p_task_id          Task ID of the Task to be considered
   * @param    p_start            Start Date Time of the Window
   * @param    p_end              End Date Time of the Window
   * @param    p_resource_id      Resource ID (Optional)
   * @param    p_resource_type    Resource Type (Optional)
   * @param    x_skilled_res_tbl  Skilled Resource Table
   */
  PROCEDURE get_skilled_resources(
    p_task_id          IN        NUMBER
  , p_start            IN        DATE
  , p_end              IN        DATE
  , p_resource_id      IN        NUMBER   DEFAULT NULL
  , p_resource_type    IN        VARCHAR2 DEFAULT NULL
  , x_skilled_res_tbl OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  ) IS
    l_levelmatch   CONSTANT NUMBER := NVL(fnd_profile.VALUE('CSF_SKILL_LEVEL_MATCH'), 2);
    j                       PLS_INTEGER;

    CURSOR c_resource_plan_window IS
      SELECT rs.resource_id
         , rs.resource_type
         , rs.winstart
         , rs.winend
         , rs.count_of_matching_skills
         , rs.skill_level
      FROM (SELECT rs.resource_id
                 , rs.resource_type
                 , GREATEST(
                       MAX(rs.start_date_active)
                     , NVL(MAX(ss.start_date_active), p_start)
                     , p_start
                     ) winstart
                 , LEAST(
                       NVL(MIN(rs.end_date_active + 1), p_end)
                     , NVL(MIN(ss.end_date_active + 1), p_end)
                     , p_end
                     ) winend
                 , COUNT(*) count_of_matching_skills
                 , SUM( 1/rsl.step_value ) skill_level
              FROM csf_resource_skills_b rs
                 , csf_required_skills_b ts
                 , csf_skill_levels_b rsl
                 , csf_skill_levels_b tsl
                 , csf_skills_b ss
             WHERE DECODE(
                       SIGN(rsl.step_value - tsl.step_value)
                     , -1, DECODE(l_levelmatch, 1, 'Y', 'N')
                     , 0, 'Y'
                     , 1, DECODE(l_levelmatch, 3, 'Y', 'N')
                     ) = 'Y'
               AND rsl.skill_level_id = rs.skill_level_id
               AND tsl.skill_level_id = ts.skill_level_id
               AND TRUNC(rs.start_date_active) < p_end
               AND (TRUNC(rs.end_date_active + 1) > p_start OR rs.end_date_active IS NULL)
               AND (rs.resource_id = p_resource_id OR p_resource_id IS NULL)
               AND (rs.resource_type = p_resource_type OR p_resource_type IS NULL)
               AND NVL(ts.disabled_flag, 'N') <> 'Y'
               AND ts.has_skill_type = 'TASK'
               AND ts.has_skill_id = p_task_id
               AND ss.skill_id(+) = rs.skill_id
               AND (
                             ts.skill_type_id NOT IN (2, 3)
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND TRUNC(ss.start_date_active) < SYSDATE
                         AND TRUNC(NVL(ss.end_date_active, SYSDATE) + 1) > SYSDATE
                     OR      ts.skill_type_id = 2
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND EXISTS (SELECT 1 FROM mtl_system_items_kfv msi WHERE msi.inventory_item_id = rs.skill_id)
                     OR      ts.skill_type_id = 3
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND EXISTS (SELECT 1
                                       FROM mtl_item_categories mic
                                      WHERE mic.category_id = rs.skill_id
                                        AND category_set_id = fnd_profile.VALUE('CS_SR_DEFAULT_CATEGORY_SET'))
               /*      OR     ts.skill_type_id = 2
                         AND rs.skill_type_id = 3
                         AND NOT EXISTS (SELECT 1
                                           FROM csf_required_skills_b ts2
                                              , mtl_item_categories mic
                                          WHERE NVL(ts2.disabled_flag, 'N') <> 'Y'
                                            AND ts2.has_skill_type = ts.has_skill_type
                                            AND ts2.has_skill_id = ts.has_skill_id
                                            AND ts2.required_skill_id <> ts.required_skill_id
                                            AND ts2.skill_type_id = 3
                                            AND mic.inventory_item_id = ts.skill_id
                                            AND mic.category_set_id = fnd_profile.VALUE('CS_SR_DEFAULT_CATEGORY_SET')
                                            AND mic.category_id = ts2.skill_id)
                         AND NOT EXISTS (SELECT 1
                                           FROM csf_resource_skills_b rs2
                                          WHERE TRUNC(rs2.start_date_active) < p_end
                                            AND (TRUNC(rs2.end_date_active + 1) > p_start OR rs2.end_date_active IS NULL)
                                            AND rs2.resource_id = rs.resource_id
                                            AND rs2.skill_id = ts.skill_id
                                            AND rs2.skill_type_id = ts.skill_type_id)
                         AND EXISTS (SELECT category_id
                                       FROM mtl_item_categories mic
                                      WHERE mic.inventory_item_id = ts.skill_id
                                        AND mic.category_set_id = fnd_profile.VALUE('CS_SR_DEFAULT_CATEGORY_SET')
                                        AND mic.category_id = rs.skill_id) */
                   )
             GROUP BY rs.resource_id, rs.resource_type) rs
          , (
              SELECT COUNT(*) count_of_req_skills
                FROM csf_required_skills_b
               WHERE NVL(disabled_flag, 'N') <> 'Y'
                 AND has_skill_type = 'TASK'
                 AND has_skill_id = p_task_id
            ) ts
     WHERE rs.count_of_matching_skills = ts.count_of_req_skills
       AND rs.winstart < rs.winend;


  BEGIN
    x_skilled_res_tbl.DELETE;
    j := 0;
    FOR i IN c_resource_plan_window LOOP
      j := j + 1;
      x_skilled_res_tbl(j).resource_id   := i.resource_id;
      x_skilled_res_tbl(j).resource_type := i.resource_type;
      x_skilled_res_tbl(j).start_date    := i.winstart;
      x_skilled_res_tbl(j).end_date      := i.winend;
      x_skilled_res_tbl(j).terr_id       := -1;
      x_skilled_res_tbl(j).terr_rank     := -1;
      x_skilled_res_tbl(j).skill_level   := i.skill_level;
      x_skilled_res_tbl(j).preference_type := 'SK';
    END LOOP;
  END get_skilled_resources;

  /**
   * Sorts the Resources in the given list based on their distance to the given
   * Task from their Home Address.
   *
   * If the Task doesnt have a valid Geometry, then the API doesnt do anything. It
   * merely returns the original list of resources without sorting.
   * <br>
   * Each Resource in the given list is picked up iteratively and its Geo-Distance
   * from the Task is computed using the Geometry of the Task and that of the
   * Resource Home Address (Location Finder will be invoked if necessary).
   *
   * @param   p_unsorted_res_tbl  List of UnSorted Resources
   * @param   p_task_id           Task ID of the Task to be performed
   * @param   p_start             Start of the Window to get that Period's Address
   * @param   p_end               End of the Window to get that Period's Address
   * @returns Sorted Resources List (JTF_ASSIGN_PUB.ASSIGNRESOURCES_TBL_TYPE)
   */
  FUNCTION sort_resource_by_distance(
    p_unsorted_res_tbl   jtf_assign_pub.assignresources_tbl_type
  , p_task_id            NUMBER
  , p_start              DATE
  , p_end                DATE
  )
    RETURN jtf_assign_pub.assignresources_tbl_type IS
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_sorted_res_tbl   jtf_assign_pub.assignresources_tbl_type;
    l_res_dist_tbl     csf_resource_tbl;
    i                  PLS_INTEGER;
    j                  PLS_INTEGER;
    l_pref_res_cnt     PLS_INTEGER;
    l_address          csf_resource_address_pvt.address_rec_type;
    l_geometry         MDSYS.SDO_GEOMETRY;
    l_task_lat         NUMBER;
    l_task_lon         NUMBER;
    l_res_lat          NUMBER;
    l_res_lon          NUMBER;
    l_res_position     MDSYS.SDO_POINT_TYPE;
    l_valid_geo        VARCHAR2(5);
    l_distance         NUMBER;

    CURSOR c_task_geometry IS
      SELECT l.geometry
        FROM jtf_tasks_b t, hz_locations l
       WHERE t.task_id = p_task_id
         AND l.location_id = csf_tasks_pub.get_task_location_id(t.task_id, t.address_id, t.location_id);

    CURSOR c_sorted_resources IS
      SELECT resource_index
           , distance
        FROM TABLE(CAST(l_res_dist_tbl AS csf_resource_tbl) )
       ORDER BY preferred_resource_flag desc, distance, resource_index;
  BEGIN
    -- Validate the Geometry of the Task.
    -- If Task has no or invalid geometry, no need to sort by distance at all
    OPEN c_task_geometry;
    FETCH c_task_geometry INTO l_geometry;
    CLOSE c_task_geometry;

    IF l_geometry IS NULL THEN
      RETURN p_unsorted_res_tbl;
    END IF;

    csf_locus_pub.verify_locus(
      p_api_version       => 1.0
    , x_msg_count         => l_msg_count
    , x_msg_data          => l_msg_data
    , x_return_status     => l_return_status
    , p_locus             => l_geometry
    , x_result            => l_valid_geo
    );

    IF l_valid_geo = 'FALSE' THEN
      RETURN p_unsorted_res_tbl;
    END IF;

     IF l_geometry.sdo_elem_info IS NOT NULL
         AND l_geometry.sdo_ordinates IS NOT NULL
     THEN
          l_task_lon :=  ROUND(l_geometry.sdo_ordinates(1), 8);
          l_task_lat  :=  ROUND(l_geometry.sdo_ordinates(2), 8);
     ELSIF l_geometry.sdo_point IS NOT NULL
     THEN
          l_task_lon :=  ROUND(l_geometry.sdo_point.x, 8);
          l_task_lat :=  ROUND(l_geometry.sdo_point.y, 8);
     ELSE
          l_task_lon := -9999;
          l_task_lat := -9999;
     END IF;

    l_res_dist_tbl := csf_resource_tbl();
    i := p_unsorted_res_tbl.FIRST;
    l_pref_res_cnt := 1;
    WHILE i IS NOT NULL LOOP
      l_res_position := get_location(p_unsorted_res_tbl(i).resource_id, p_unsorted_res_tbl(i).resource_type, p_start);

      IF l_res_position IS NOT NULL AND l_res_position.x <> -9999 AND l_res_position.y <> -9999 THEN
        l_distance := geo_distance(l_task_lon, l_task_lat, l_res_position.x, l_res_position.y);
      ELSE
        l_distance := fnd_api.g_miss_num;
      END IF;

      l_res_dist_tbl.EXTEND;
      l_res_dist_tbl(i) :=
        csf_resource(
            'N'
          , i
          , l_distance
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          );

      IF p_unsorted_res_tbl(i).preference_type = 'I' OR p_unsorted_res_tbl(i).preference_type = 'C' THEN
        l_res_dist_tbl(i).preferred_resource_flag := 'Y';
      END IF;

      i := p_unsorted_res_tbl.NEXT(i);
    END LOOP;

    i := 0;
    FOR v_resource IN c_sorted_resources LOOP
      i := i + 1;
      l_sorted_res_tbl(i) := p_unsorted_res_tbl(v_resource.resource_index);
    END LOOP;
    RETURN l_sorted_res_tbl;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_unsorted_res_tbl;
  END sort_resource_by_distance;

  /**
   * Reduce the number of Resources passed to a maximum value as determined by
   * the profile "CSR: Maximum number of Resources".
   *
   * The API doesnt delete resources as such. It first prunes the resource list
   * by considering only those Resources who have valid Shift Definitions between
   * the given dates and then give the top N resources. Note that it will be
   * better if the Resources are already sorted in the order of their preference.
   *
   * @param   p_res_tbl  List of Sorted Resources
   * @param   p_start    Start of the Window for Valid Shifts Consideration
   * @param   p_end      End of the Window for Valid Shifts Consideration
   * @returns Top N Resources as determined by the MAXNRSELECTEDRES profile.
   */
  FUNCTION reduce_resource_list(
    p_res_tbl IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_start   DATE
  , p_end     DATE
  )
    RETURN jtf_assign_pub.assignresources_tbl_type IS
    l_max_resources  NUMBER;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_shift_tbl      jtf_calendar_pub.shift_tbl_type;
    l_out_tbl        jtf_assign_pub.assignresources_tbl_type;
    i                PLS_INTEGER;
    j                PLS_INTEGER;
    cnt              PLS_INTEGER;
  BEGIN
    -- Get the maximum number of allowed Resources
    -- Modified to get the profile value from Scheduler API
    l_max_resources := csr_scheduler_pub.get_sch_parameter_value('spMaxResources');

    -- Validate retrieved maximum value
    IF NVL(l_max_resources, 0) <= 0 THEN
      l_max_resources := p_res_tbl.COUNT;
    END IF;

    i := p_res_tbl.FIRST;
    j := 0;


    WHILE i IS NOT NULL LOOP
      cnt:= p_res_tbl.NEXT(i);
      WHILE cnt <= p_res_tbl.LAST LOOP
        IF p_res_tbl(i).resource_id = p_res_tbl(cnt).resource_id AND
          p_res_tbl(i).resource_type = p_res_tbl(cnt).resource_type THEN
          p_res_tbl.delete(cnt);
        END IF;
        cnt:= p_res_tbl.next(cnt);
      END LOOP;

      jtf_calendar_pub.get_resource_shifts(
        p_api_version       => 1
      , p_init_msg_list     => fnd_api.g_true
      , x_return_status     => l_return_status
      , x_msg_count         => l_msg_count
      , x_msg_data          => l_msg_data
      , p_resource_id       => p_res_tbl(i).resource_id
      , p_resource_type     => p_res_tbl(i).resource_type
      , p_start_date        => p_start
      , p_end_date          => p_end
      , x_shift             => l_shift_tbl
      );


      IF l_return_status = fnd_api.g_ret_sts_success OR l_shift_tbl.COUNT > 0 THEN
        j := j + 1;
        l_out_tbl(j) := p_res_tbl(i);
        EXIT WHEN j = l_max_resources;
      END IF;
      i := p_res_tbl.NEXT(i);
    END LOOP;


    RETURN l_out_tbl;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_res_tbl;
  END reduce_resource_list;

  /**
   * Returns the Error Message that is encountered during Resource Selection
   * process based on the Flags passed. Each Flag corresponds to a But in the
   * Error Message Table. See INIT_ASSIGN_ERRORS for more information.
   *
   * @param   p_flags   Flags used to select Resources for the Task
   * @return  Name of the Error Message encountered.
   */
  FUNCTION get_assign_error_msg(p_flags IN NUMBER)
    RETURN VARCHAR2 IS
    l_msg VARCHAR2(100);
  BEGIN
    l_msg := 'CSF_R_NO_RES_FOR_TASK';
    IF p_flags IS NOT NULL AND g_assign_errors.EXISTS(p_flags) THEN
      l_msg := g_assign_errors(p_flags);
    END IF;
    RETURN l_msg;
  END get_assign_error_msg;

  /**
   * Adds the suggested resources to the end of the given resource table if
   * the resource is not already present in the resource table.
   * @param p_res_tbl                Resource Table and where suggested res will be added
   * @param p_suggested_res_id_tbl   Suggested Resource ID Table
   * @param p_suggested_res_type_tbl Suggested Resource Type Table
   */
  PROCEDURE add_suggested_resources(
    p_res_tbl                IN OUT NOCOPY jtf_assign_pub.assignresources_tbl_type
  , p_suggested_res_id_tbl   IN            jtf_number_table
  , p_suggested_res_type_tbl IN            jtf_varchar2_table_100
  , p_start_date             IN            DATE
  , p_end_date               IN            DATE
  ) IS
    i           PLS_INTEGER;
    j           PLS_INTEGER;
    l_res_found BOOLEAN;
  BEGIN
    -- Validate the Inputs.
    IF    p_suggested_res_id_tbl IS NULL
       OR p_suggested_res_type_tbl IS NULL
       OR p_suggested_res_id_tbl.COUNT <= 0
       OR p_suggested_res_type_tbl.COUNT <> p_suggested_res_id_tbl.COUNT
    THEN
      RETURN;
    END IF;

    -- Add each Suggested Resource Info to the Resource List if its not already present.
    j := p_suggested_res_id_tbl.FIRST;
    WHILE j IS NOT NULL LOOP

      -- Check whether the Resource list already has the Suggested Resource.
      l_res_found := FALSE;
      i := p_res_tbl.FIRST;
      WHILE i IS NOT NULL LOOP
        l_res_found :=      p_res_tbl(i).resource_id   = p_suggested_res_id_tbl(j)
                        AND p_res_tbl(i).resource_type = p_suggested_res_type_tbl(j);

        EXIT WHEN l_res_found;
        i := p_res_tbl.NEXT(i);
      END LOOP;

      IF NOT l_res_found THEN
        i := NVL(p_res_tbl.LAST, 0) + 1;

        p_res_tbl(i).resource_id              := p_suggested_res_id_tbl(j);
        p_res_tbl(i).resource_type            := p_suggested_res_type_tbl(j);
        p_res_tbl(i).start_date               := p_start_date;
        p_res_tbl(i).end_date                 := p_end_date;
        p_res_tbl(i).terr_id                  := -1;
        p_res_tbl(i).terr_rank                := -1;
      END IF;

      j := p_suggested_res_id_tbl.NEXT(j);
    END LOOP;
  END add_suggested_resources;


  /**
   * Gets the Qualified Resources for a Task by calling JTF Assignment Manager
   * and also making use of the Required Skills of the Task if Required to reduce
   * the Resource List.
   *
   * <br>
   *
   * The reason for CSF to maintain its own Assignment Manager rather than
   * completely relying on JTF Assignment Manager has two fold reasons.
   *
   * <br>
   *
   * TQ is secondary for JTF Assignment Manager API.
   *    Suppose in Schedule Advise Window, all the Flags are checked... then
   *    JTF Assignment Manager will give preference to Contracts and IB only.
   *    Only when both of returns ZERO resources, then JTF will consider TQ.
   *    But DC expects an intersection of the three results.
   *    Moreover if both Contracts and IB are checked, then JTF will use
   *    the profile "JTFAM: Resource Search Order (JTF_AM_PREF_RES_ORDER)" to
   *    find out which one to return ultimately. If the value CONTRACTS, then
   *      CONTRACTS - Only Contracts is returned. If None, IB is returned.
   *      IB        - Only IB is returned. If None, Contracts is returned.
   *      BOTH      - Intersection of Contracts and IB Resources are returned.
   *
   * <br>
   *
   * JTF doesnt know "ABC of Skills"
   *    Resources and Skills is completely a Field Service Functionality. A
   *    Resource can be attached to a Skill with a particular Skill Level.
   *    So can a Task be tied to a Skill with a particular Skill Level. If
   *    Skill based Flag is checked, then the Resource needs to have the same
   *    Skill Set with a Comparable Skill Level as required by the Task.
   *    Comparable Skill Level !!! - What is that ?
   *    The profile "CSF: Skill Level Match (CSF_SKILL_LEVEL_MATCH)" is used
   *    to decide whether the Resource has the Required Skill Level as required
   *    by the Task.
   *      EQUAL TO OR SMALLER THAN - Resource should have a Skill Level equal to
   *                                 or lesser than that of the Task.
   *      EQUAL TO                 - Resource should have a Skill Level equal to
   *                                 that of the Task.
   *      EQUAL TO OR GREATER THAN - Resource should have a Skill Level equal to
   *                                 or greater than that of the Task.
   *    Note that the Task needs to have Skills. Otherwise the Flag wont be used
   *    at all for getting the Qualified Resources.
   *
   * <br>
   *
   * Thus CSF Assignment Manager API will call JTF Assignment Manager separately
   * for Contracts / IB and then for Territory. Do an intersection of the Resources
   * obtained thru the two calls and pruned by Skill Sets. Note that it gets
   * Contracts / IB Resources from JTF in one call and so the user should make use
   * the profile JTF_AM_PREF_RES_ORDER to get intersected results.
   *
   * <br>
   *
   * CSF Assignment Manager still doesnt pass the parameter P_FILTER_EXCLUDED_RESOURCE
   * so that JTF Assignment Manager doesnt return Excluded Resources.
   * CSF Assignment Manager still doesnt pass the parameter P_BUSINESS_PROCESS_ID
   * so that JTF Assignment Manager returns only those Resources who belong to
   * Field Service Business Process when Preferred Resources are entered in Contracts.
   *
   * @param   p_api_version             API Version (1.0)
   * @param   p_init_msg_list           Initialize Message List
   * @param   x_return_status           Return Status of the Procedure.
   * @param   x_msg_count               Number of Messages in the Stack.
   * @param   x_msg_data                Stack of Error Messages.
   * @param   p_task_id                 Task Idenfifier
   * @param   p_task_rec                Qualified Task Record
   * @param   p_scheduling_mode         Scheduling Mode used. (A, I, W)
   * @param   p_start                   Start Date of the Plan Window
   * @param   p_end                     End Date of the Plan Window
   * @param   p_duration                Duration of the Task (Used by JTF to find out Available Resources)
   * @param   p_duration_uom            UOM of the above Duration
   * @param   p_contracts_flag          Get Contracts Preferred Resources ('Y'/'N')
   * @param   p_ib_flag                 Get IB Preferred Resources ('Y'/'N')
   * @param   p_territory_flag          Get Winning Territory Resources ('Y'/'N')
   * @param   p_skill_flag              Get Skilled Resources ('Y'/'N')
   * @param   p_calendar_flag           Get only Available Resources. Passed to JTF ('Y'/'N')
   * @param   p_sort_flag               Sort the Resources based on their distance from Task ('Y'/'N')
   * @param   p_suggested_res_id_tbl    Suggested Resource ID Table
   * @param   p_suggested_res_type_tbl  Suggested Resource Type Table
   * @param   x_res_tbl                 Qualified Resource suitable for Scheduling
   */
  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_incident_id            IN              NUMBER
  , p_res_qualifier_tbl      IN              resource_qualifier_tbl_type
  , p_scheduling_mode        IN              VARCHAR2
  , p_start                  IN              DATE
  , p_end                    IN              DATE
  , p_duration               IN              NUMBER
  , p_duration_uom           IN              VARCHAR2
  , p_contracts_flag         IN              VARCHAR2
  , p_ib_flag                IN              VARCHAR2
  , p_territory_flag         IN              VARCHAR2
  , p_skill_flag             IN              VARCHAR2
  , p_calendar_flag          IN              VARCHAR2
  , p_sort_flag              IN              VARCHAR2
  , p_suggested_res_id_tbl   IN              jtf_number_table
  , p_suggested_res_type_tbl IN              jtf_varchar2_table_100
  , x_res_tbl                OUT NOCOPY      jtf_assign_pub.assignresources_tbl_type
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_RESOURCES_TO_SCHEDULE';
    l_api_version   CONSTANT NUMBER       := 1.0;

    l_end_date               DATE;
    l_task_has_skill_id      NUMBER;
    l_business_process_id    NUMBER;
    l_contracts_flag         VARCHAR2(1);
    l_ib_flag                VARCHAR2(1);
    l_territory_flag         VARCHAR2(1);
    l_skills_flag            VARCHAR2(1);
    l_has_suggested_res      BOOLEAN;
    l_continue_search        BOOLEAN;
    l_cont_ib_res_found      BOOLEAN := TRUE;
    l_terr_res_found         BOOLEAN := TRUE;
    l_sr_task_rec            jtf_assign_pub.jtf_srv_task_rec_type;

    l_contracts_ib_res_tbl   jtf_assign_pub.assignresources_tbl_type;
    l_territory_res_tbl      jtf_assign_pub.assignresources_tbl_type;
    l_skilled_res_tbl        jtf_assign_pub.assignresources_tbl_type;
    l_stic                   NUMBER;

    e_no_res                 EXCEPTION;

    -- Cursor to determine if the Task has any required skills
    -- and returns the has_skill_id
    CURSOR c_task_skills  IS
      SELECT has_skill_id
        FROM csf_required_skills_b,jtf_tasks_b t
       WHERE t.task_id = p_task_id
         AND has_skill_type = 'TASK'
         AND has_skill_id = nvl(t.parent_task_id, t.task_id)
         AND NVL(disabled_flag, 'N') <> 'Y'
         AND NVL(t.deleted_flag, 'N') <> 'Y';

    --Introduced by lokumar for bug#7340932
    CURSOR c_business_process IS
      select iv.business_process_id
        from jtf_tasks_b t, cs_incidents_all i, cs_incident_types_vl iv
       where t.task_id = p_task_id
         and t.source_object_id = i.incident_id
         and i.incident_type_id = iv.incident_type_id;


  BEGIN

    debug( fnd_log.level_statement, l_api_name, 'Get Resources To Schedule API Started');

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    IF csf_util_pvt.g_timing_activated THEN
      csf_util_pvt.add_timer(105, 'Get resources to schedule (init)', 0, NULL);
    END IF;


    debug( fnd_log.level_statement, l_api_name,    ' Task ID:'         || p_task_id
                                                || ' Incident Id:'     || p_incident_id
                                                || ' Scheduling Mode:' || p_scheduling_mode
                                                || ' Start Date:'      || to_char(p_start, 'DD-MON-YYYY HH24:MI:SS')
                                                || ' End Date:'        || to_char(p_end  , 'DD-MON-YYYY HH24:MI:SS')
                                                || ' Calendar Flag:'   || p_calendar_flag
                                                || ' Sort Flag:'       || p_sort_flag
                                                || ' Contracts Flag:'  || p_contracts_flag
                                                || ' IB Flag:'         || p_ib_flag
                                                || ' Terr Flag:'       || p_territory_flag
                                                || ' Skills Flag:'     || p_skill_flag
                                                );

    l_contracts_flag    := NVL(p_contracts_flag, 'N');
    l_ib_flag           := NVL(p_ib_flag, 'N');
    l_territory_flag    := NVL(p_territory_flag, 'N');
    l_skills_flag       := NVL(p_skill_flag, 'N');
    l_stic              := 0;
    l_has_suggested_res := p_suggested_res_id_tbl IS NOT NULL AND p_suggested_res_id_tbl.COUNT > 0;

    -- Check that at least one flag has been set.
    IF    l_contracts_flag = 'N'
      AND l_ib_flag = 'N'
      AND l_territory_flag = 'N'
      AND l_skills_flag = 'N'
      AND NOT l_has_suggested_res
    THEN
      debug( fnd_log.level_statement, l_api_name, 'No Resource Selection Criteria is specified');
      RAISE e_no_res;
    END IF;

    -- start with an empty list
    x_res_tbl.DELETE;

    -- Find out whether the Task has any Required Skills Attached.
    IF l_skills_flag = 'Y' THEN
      debug( fnd_log.level_statement, l_api_name, 'Resource Selection is based on Skills..finding out the skills');
      OPEN c_task_skills;
      FETCH c_task_skills INTO l_task_has_skill_id;
      CLOSE c_task_skills;

      debug( fnd_log.level_statement, l_api_name, 'The Skill ID:' || l_task_has_skill_id);
      IF l_task_has_skill_id IS NULL THEN
        -- Task has no Skills attached. Turn off Skills Flag.
        debug( fnd_log.level_statement, l_api_name, 'Task has no skills attached..turning off Skills qualifiers');
        l_skills_flag := 'N';
        -- If none of the other Flags are set we have an error situation
        IF l_contracts_flag = 'N' AND l_ib_flag = 'N' AND l_territory_flag = 'N' AND NOT l_has_suggested_res THEN
          fnd_message.set_name('CSF', 'CSF_NO_TASK_SKILL_RES');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    -- Convert the given Task ID or the Qualifier Table to SR Task Record
    IF l_contracts_flag = 'Y' OR l_ib_flag = 'Y' OR l_territory_flag = 'Y'  THEN
      debug( fnd_log.level_statement, l_api_name, 'The input resource qualifier table count:'||p_res_qualifier_tbl.COUNT);
      IF p_res_qualifier_tbl.COUNT > 0 THEN
        IF csf_util_pvt.g_timing_activated THEN
          csf_util_pvt.add_timer(106, 'convert territory qualifiers to record', 0, NULL);
        END IF;
        l_sr_task_rec := get_qualified_task_rec(p_res_qualifier_tbl);
        IF csf_util_pvt.g_timing_activated THEN
          csf_util_pvt.add_timer(106, 'convert territory qualifiers to record', 1, NULL);
        END IF;
      ELSE
        IF csf_util_pvt.g_timing_activated THEN
          csf_util_pvt.add_timer(107, 'get territory qualifiers for task', 0, NULL);
        END IF;
        l_sr_task_rec := get_qualified_task_rec(get_res_qualifier_table(p_task_id));
        IF csf_util_pvt.g_timing_activated THEN
          csf_util_pvt.add_timer(107, 'get territory qualifiers for task', 1, NULL);
        END IF;
      END IF;
      l_sr_task_rec.task_id            := p_task_id;
      l_sr_task_rec.service_request_id := p_incident_id;
    END IF;

    debug( fnd_log.level_statement, l_api_name,      ' TASK_ID:'            || l_sr_task_rec.task_id
                                                  || ' SERVICE_REQUEST_ID:' || l_sr_task_rec.SERVICE_REQUEST_ID
                                                  || ' PARTY_ID:'           || l_sr_task_rec.PARTY_ID
                                                  || ' COUNTRY:'            || l_sr_task_rec.COUNTRY
                                                  || ' PARTY_SITE_ID:'      || l_sr_task_rec.PARTY_SITE_ID
                                                  || ' CITY:'               || l_sr_task_rec.CITY
                                                  || ' POSTAL_CODE:'        || l_sr_task_rec.POSTAL_CODE
                                                  || ' STATE:'              || l_sr_task_rec.STATE
                                                  || ' AREA_CODE:'          || l_sr_task_rec.AREA_CODE
                                                  || ' COUNTY:'             || l_sr_task_rec.COUNTY
                                                  || ' COMP_NAME_RANGE:'    || l_sr_task_rec.COMP_NAME_RANGE
                                                  || ' PROVINCE:'           || l_sr_task_rec.PROVINCE
                                                  || ' NUM_OF_EMPLOYEES:'   || l_sr_task_rec.NUM_OF_EMPLOYEES
                                                  || ' TASK_TYPE_ID:'       || l_sr_task_rec.TASK_TYPE_ID
                                                  || ' TASK_STATUS_ID:'     || l_sr_task_rec.TASK_STATUS_ID
                                                  || ' TASK_PRIORITY_ID:'   || l_sr_task_rec.TASK_PRIORITY_ID
                                                  || ' INCIDENT_TYPE_ID:'   || l_sr_task_rec.INCIDENT_TYPE_ID
                                                  || ' INCIDENT_SEVERITY_ID:'||l_sr_task_rec.INCIDENT_SEVERITY_ID
                                                  || ' INCIDENT_URGENCY_ID:'|| l_sr_task_rec.INCIDENT_URGENCY_ID
                                                  || ' PROBLEM_CODE:'       || l_sr_task_rec.PROBLEM_CODE
                                                  || ' INCIDENT_STATUS_ID:' || l_sr_task_rec.INCIDENT_STATUS_ID
                                                  || ' SUPPORT_SITE_ID:'    || l_sr_task_rec.SUPPORT_SITE_ID
                                                  || ' CUSTOMER_SITE_ID:'   || l_sr_task_rec.CUSTOMER_SITE_ID
                                                  || ' INVENTORY_ITEM_ID:'  || l_sr_task_rec.INVENTORY_ITEM_ID
                                                  || ' DAY_OF_WEEK:'        || l_sr_task_rec.DAY_OF_WEEK
                                                  || ' TIME_OF_DAY:'        || l_sr_task_rec.TIME_OF_DAY
                                                  || ' ORGANIZATION_ID:'    || l_sr_task_rec.ORGANIZATION_ID
                                                  );
    IF csf_util_pvt.g_timing_activated THEN
      csf_util_pvt.add_timer(105, 'get resources to schedule (init)', 1, NULL);
    END IF;

    l_continue_search := TRUE;


    IF csr_scheduler_pub.get_sch_parameter_value('spEnforcePlanWindow') = 'NONE' THEN
      debug( fnd_log.level_statement, l_api_name, ' Enforce None; End Date:'|| to_char(p_end, 'DD-MON-YYYY HH24:MI:SS'));
      l_end_date := p_end + NVL(csr_scheduler_pub.get_sch_parameter_value('spPlanScope'), 5)/5;
    ELSE
      debug( fnd_log.level_statement, l_api_name, ' Enforce is Not None; End Date:'|| to_char(p_end, 'DD-MON-YYYY HH24:MI:SS'));
      l_end_date := p_end;
    END IF;

    debug( fnd_log.level_statement, l_api_name,   'Resource Search Window Start:'||to_char(p_start, 'DD-MON-YYYY HH24:MI:SS')
                                               || 'Resource Search Window End:'  ||to_char(p_end, 'DD-MON-YYYY HH24:MI:SS')
                                               );

    -- Retrieve the Resources defined in Contracts / IB
    IF l_contracts_flag = 'Y' OR l_ib_flag = 'Y' THEN
      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(108, 'Get contract/IB resources', 0, NULL);
      END IF;

      IF l_contracts_flag = 'Y' THEN
        -- Added by lokumar for bug#7340932
        --business process id is used only when contracts are selected
        OPEN c_business_process;
        FETCH c_business_process INTO l_business_process_id;
        CLOSE c_business_process;

        debug( fnd_log.level_statement, l_api_name, 'The Business Process ID used for fetching Contracts Pref Resources:' || l_business_process_id);

        l_stic := l_stic + 1;

      END IF;

      IF l_ib_flag = 'Y' THEN
        l_stic := l_stic + 2;
      END IF;

      jtf_assign_pub.get_assign_resources(
        p_api_version                   => 1.0
      , p_init_msg_list                 => fnd_api.g_false
      , p_commit                        => fnd_api.g_false
      , x_return_status                 => x_return_status
      , x_msg_count                     => x_msg_count
      , x_msg_data                      => x_msg_data
      , p_sr_task_rec                   => l_sr_task_rec
      , p_contracts_preferred_engineer  => l_contracts_flag
      , p_ib_preferred_engineer         => l_ib_flag
      , p_territory_flag                => 'N'
      , p_effort_duration               => p_duration
      , p_effort_uom                    => p_duration_uom
      , p_start_date                    => p_start
      , p_end_date                      => l_end_date
      , p_auto_select_flag              => 'N'
      , p_calendar_flag                 => NVL(p_calendar_flag, 'N')
      , p_calendar_check                => 'N'
      , p_calling_doc_id                => l_sr_task_rec.service_request_id
      , p_calling_doc_type              => g_assign_doc_type
      , p_business_process_id           => l_business_process_id
      , x_assign_resources_tbl          => l_contracts_ib_res_tbl
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      debug( fnd_log.level_statement, l_api_name, 'The Number of Resources found using Contracts/IB:' || l_contracts_ib_res_tbl.COUNT);

      IF l_contracts_ib_res_tbl.COUNT = 0 THEN
        l_cont_ib_res_found := FALSE;
      END IF;

      FOR i in 1..l_contracts_ib_res_tbl.COUNT
      LOOP
        debug( fnd_log.level_statement, l_api_name, 'Obtained C/IB resource:' || l_contracts_ib_res_tbl(i).resource_id || l_contracts_ib_res_tbl(i).resource_type );
      END LOOP;

      -- Since JTF Assignment Manager doesnt return End Windows properly,
      -- setting them to the given Plan Window.
      set_generic_planwindow(l_contracts_ib_res_tbl, p_start, l_end_date);

      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(108, 'get contract/IB resources', 1, NULL);
      END IF;
    END IF;

    -- Retrieve Resources from Territory
    IF l_territory_flag = 'Y' AND l_continue_search THEN
      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(109, 'get territory resources', 0, NULL);
      END IF;

      l_stic := l_stic + 4;


      jtf_assign_pub.get_assign_resources(
        p_api_version                   => 1.0
      , p_init_msg_list                 => fnd_api.g_false
      , p_commit                        => fnd_api.g_false
      , x_return_status                 => x_return_status
      , x_msg_count                     => x_msg_count
      , x_msg_data                      => x_msg_data
      , p_sr_task_rec                   => l_sr_task_rec
      , p_contracts_preferred_engineer  => 'N'
      , p_ib_preferred_engineer         => 'N'
      , p_territory_flag                => 'Y'
      , p_effort_duration               => p_duration
      , p_effort_uom                    => p_duration_uom
      , p_start_date                    => p_start
      , p_end_date                      => l_end_date
      , p_auto_select_flag              => 'N'
      , p_calendar_flag                 => NVL(p_calendar_flag, 'N')
      , p_calendar_check                => 'N'
      , p_calling_doc_id                => l_sr_task_rec.service_request_id
      , p_calling_doc_type              => g_assign_doc_type
      , x_assign_resources_tbl          => l_territory_res_tbl
      );


      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      debug( fnd_log.level_statement, l_api_name, 'The Number of Resources found using Territories:' || l_territory_res_tbl.COUNT);

      IF l_territory_res_tbl.COUNT = 0 THEN
        l_terr_res_found := FALSE;
      END IF;

      FOR i in 1..l_territory_res_tbl.COUNT
      LOOP
        debug( fnd_log.level_statement, l_api_name, 'Obtained Terr resource:' || l_territory_res_tbl(i).resource_id || l_territory_res_tbl(i).resource_type );
      END LOOP;


      -- Since JTF Assignment Manager doesnt return End Windows properly,
      -- setting them to the given Plan Window.
      set_generic_planwindow(l_territory_res_tbl, p_start, l_end_date);

      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(109, 'get territory resources', 1, NULL);
      END IF;
    END IF;

    -- This is done for two cases: a) when res found in TQ/IB/Cont or b) when TQ/IB/Cont
    -- was not used as the resource selection criteria
    IF NOT l_terr_res_found AND NOT l_cont_ib_res_found
    THEN
      debug( fnd_log.level_statement, l_api_name, 'Search will not be continued');
      l_continue_search := FALSE;
    END IF;

    -- Retrieve the Skilled Resources for the Task
    IF l_skills_flag = 'Y' AND l_continue_search THEN
      debug( fnd_log.level_statement, l_api_name, 'Retrieving Skilled Resources for the Task');
      l_stic := l_stic + 8;
      get_skilled_resources(
        p_task_id         => l_task_has_skill_id
      , p_start           => p_start
      , p_end             => l_end_date
      , x_skilled_res_tbl => l_skilled_res_tbl
      );
      debug( fnd_log.level_statement, l_api_name, 'Retrieving Skilled Resources for the Task');
      IF l_skilled_res_tbl.COUNT = 0 THEN
        debug( fnd_log.level_statement, l_api_name, 'No Resources Found using Skills Qualifiers');
        l_continue_search := FALSE;
      END IF;

      FOR i in 1..l_skilled_res_tbl.COUNT
      LOOP
        debug( fnd_log.level_statement, l_api_name, 'Obtained skills resource:' || l_skilled_res_tbl(i).resource_id || l_skilled_res_tbl(i).resource_type );
      END LOOP;

    END IF;

    debug( fnd_log.level_statement, l_api_name, 'l_stic value:' || l_stic);

    -- Intersect the results obtained from the three Qualifiers.
    IF l_continue_search THEN
      IF l_stic > 0 AND l_stic <= 3 THEN  --> Only Contracts / IB was chosen
        debug( fnd_log.level_statement, l_api_name, 'Only Contracts / IB was chosen');
        x_res_tbl := l_contracts_ib_res_tbl;
      ELSIF l_stic = 4 THEN               --> Only Territory was chosen
        debug( fnd_log.level_statement, l_api_name, 'Only Territory was chosen');
        x_res_tbl := l_territory_res_tbl;
      ELSIF l_stic = 8 THEN               --> Only Skills were chosen
        debug( fnd_log.level_statement, l_api_name, 'Only Skills were chosen');
        x_res_tbl := l_skilled_res_tbl;
      ELSIF l_stic <= 7 THEN              --> Both Contracts/IB and Terr were chosen
        debug( fnd_log.level_statement, l_api_name, 'Both Contracts/IB and Terr were chosen');
        x_res_tbl := union_results(l_contracts_ib_res_tbl, l_territory_res_tbl);
      ELSIF l_stic <= 11 THEN             --> Both Contracts/IB and Skills where chosen
        debug( fnd_log.level_statement, l_api_name, 'Both Contracts/IB and Skills where chosen');
        x_res_tbl := intersect_results(l_contracts_ib_res_tbl, l_skilled_res_tbl, p_start, l_end_date);
      ELSIF l_stic <= 12 THEN             --> Both Terr and SKills were chosen
        debug( fnd_log.level_statement, l_api_name, 'Both Terr and SKills were chosen');
        x_res_tbl := intersect_results(l_territory_res_tbl, l_skilled_res_tbl, p_start, l_end_date);
      ELSIF l_stic <= 15 THEN             --> All the Flags were chosen
        debug( fnd_log.level_statement, l_api_name, 'All the Flags were chosen');
        x_res_tbl := union_results(l_contracts_ib_res_tbl, l_territory_res_tbl);
        x_res_tbl := intersect_results(x_res_tbl, l_skilled_res_tbl, p_start, l_end_date);
      END IF;
    END IF;

    -- Add the suggested resources at the end (if the resource is not already there)
    IF l_has_suggested_res THEN
      debug( fnd_log.level_statement, l_api_name, 'Adding the Suggested Resource');
      add_suggested_resources(
        p_res_tbl                => x_res_tbl
      , p_suggested_res_id_tbl   => p_suggested_res_id_tbl
      , p_suggested_res_type_tbl => p_suggested_res_type_tbl
      , p_start_date             => p_start
      , p_end_date               => l_end_date
      );
    END IF;

    -- make sure there were results
    IF x_res_tbl.COUNT = 0 THEN
      debug( fnd_log.level_statement, l_api_name, 'No Resources Found; Raising Exception!');
      RAISE e_no_res;
    END IF;

    IF p_scheduling_mode <> 'A' THEN
      debug( fnd_log.level_statement, l_api_name, 'Non-Assisted Mode; Sorting by distance');
      -- Sort the Resources by their distance to the Task.
      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(113, 'sort resources list', 0, NULL);
      END IF;

      IF x_res_tbl.COUNT > 1 AND NVL(p_sort_flag, 'Y') = 'Y' THEN
        x_res_tbl := sort_resource_by_distance(x_res_tbl, p_task_id, p_start, l_end_date);
      END IF;

      FOR i in 1..x_res_tbl.COUNT
      LOOP
        debug( fnd_log.level_statement, l_api_name, 'After Sorting resource:' || x_res_tbl(i).resource_id || x_res_tbl(i).resource_type );
      END LOOP;

      IF csf_util_pvt.g_timing_activated THEN
        csf_util_pvt.add_timer(113, 'sort resources list', 1, NULL);
      END IF;

    END IF;


    -- The number of Resources are restricted from the Sorted List.
    IF csf_util_pvt.g_timing_activated THEN
      csf_util_pvt.add_timer(114, 'reduce sorted resources list', 0, NULL);
    END IF;

    x_res_tbl := reduce_resource_list(x_res_tbl, p_start, l_end_date);

    FOR i in 1..x_res_tbl.COUNT
    LOOP
      debug( fnd_log.level_statement, l_api_name, 'After Calendar Check:' || x_res_tbl(i).resource_id || x_res_tbl(i).resource_type );
    END LOOP;

    IF csf_util_pvt.g_timing_activated THEN
      csf_util_pvt.add_timer(114, 'reduce sorted resources list', 1, NULL);
    END IF;
  EXCEPTION
    WHEN e_no_res THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('CSF', get_assign_error_msg(l_stic));
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_resources_to_schedule;

  /**
   * Gets the Qualified Resources for a Task in a format understood by Request Model.
   * <br>
   * In turn calls the GET_RESOURCES_TO_SCHEDULE which gets the Resources in JTF
   * Assignment Manager Format.
   */
  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2 DEFAULT NULL
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_incident_id            IN              NUMBER
  , p_res_qualifier_tbl      IN              resource_qualifier_tbl_type
  , p_scheduling_mode        IN              VARCHAR2
  , p_start                  IN              DATE
  , p_end                    IN              DATE
  , p_duration               IN              NUMBER                 DEFAULT NULL
  , p_duration_uom           IN              VARCHAR2               DEFAULT NULL
  , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
  , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
  , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
  , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
  , p_calendar_flag          IN              VARCHAR2               DEFAULT NULL
  , p_sort_flag              IN              VARCHAR2               DEFAULT NULL
  , p_suggested_res_id_tbl   IN              jtf_number_table       DEFAULT NULL
  , p_suggested_res_type_tbl IN              jtf_varchar2_table_100 DEFAULT NULL
  , x_res_tbl                IN OUT NOCOPY   csf_requests_pvt.resource_tbl_type
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_RESOURCES_TO_SCHEDULE(2)';
    l_api_version   CONSTANT NUMBER       := 1.0;

    l_assign_resource_tbl   jtf_assign_pub.assignresources_tbl_type;
    j                       PLS_INTEGER;
    k                       PLS_INTEGER;
  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;




    get_resources_to_schedule(
      p_api_version            => 1
    , p_init_msg_list          => fnd_api.g_false
    , x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_task_id                => p_task_id
    , p_incident_id            => p_incident_id
    , p_res_qualifier_tbl      => p_res_qualifier_tbl
    , p_scheduling_mode        => p_scheduling_mode
    , p_start                  => p_start
    , p_end                    => p_end
    , p_duration               => p_duration
    , p_duration_uom           => p_duration_uom
    , p_contracts_flag         => p_contracts_flag
    , p_ib_flag                => p_ib_flag
    , p_territory_flag         => p_territory_flag
    , p_skill_flag             => p_skill_flag
    , p_calendar_flag          => p_calendar_flag
    , p_sort_flag              => p_sort_flag
    , p_suggested_res_id_tbl   => p_suggested_res_id_tbl
    , p_suggested_res_type_tbl => p_suggested_res_type_tbl
    , x_res_tbl                => l_assign_resource_tbl
    );


    IF x_res_tbl IS NULL THEN
        x_res_tbl := csf_requests_pvt.resource_tbl_type();
    END IF;

    --start with an empty table so that previous value are deleted
    x_res_tbl.delete;

    -- if qualified resoucres are found, add them to the output list
    IF x_return_status = fnd_api.g_ret_sts_success AND l_assign_resource_tbl.COUNT > 0 THEN

      j := l_assign_resource_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
        x_res_tbl.EXTEND;
        k := x_res_tbl.LAST;
        x_res_tbl(k).resource_id   := l_assign_resource_tbl(j).resource_id;
        x_res_tbl(k).resource_type := l_assign_resource_tbl(j).resource_type;
        x_res_tbl(k).planwin_start := l_assign_resource_tbl(j).start_date;
        x_res_tbl(k).planwin_end   := l_assign_resource_tbl(j).end_date;
        x_res_tbl(k).territory_id  := l_assign_resource_tbl(j).terr_id;

        IF l_assign_resource_tbl(j).terr_rank = jtf_assign_pub.am_miss_num THEN
          x_res_tbl(k).territory_rank := NULL;
        ELSE
          x_res_tbl(k).territory_rank := l_assign_resource_tbl(j).terr_rank;
        END IF;
        IF l_assign_resource_tbl(j).preference_type = 'I' OR l_assign_resource_tbl(j).preference_type = 'C' THEN
          x_res_tbl(k).preferred_resources_flag := 'Y';
        ELSE
          x_res_tbl(k).preferred_resources_flag := 'N';
        END IF;

        IF l_assign_resource_tbl(j).preference_type = 'C' THEN
          x_res_tbl(k).resource_source := 'CNT';
        ELSIF l_assign_resource_tbl(j).preference_type = 'I' THEN
          x_res_tbl(k).resource_source := 'IB';
        ELSIF l_assign_resource_tbl(j).preference_type = 'SK' THEN
          x_res_tbl(k).resource_source := 'SK';
        ELSIF l_assign_resource_tbl(j).terr_id IS NOT NULL AND l_assign_resource_tbl(j).terr_id <> -1 THEN
          x_res_tbl(k).resource_source := 'TER';
        ELSE
          x_res_tbl(k).resource_source := 'RS';
        END IF;

        x_res_tbl(k).skill_level  := l_assign_resource_tbl(j).skill_level;

        j := l_assign_resource_tbl.NEXT(j);
      END LOOP;
    END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_resources_to_schedule;

  PROCEDURE get_resources_to_schedule(
    p_api_version            IN              NUMBER
  , p_init_msg_list          IN              VARCHAR2 DEFAULT NULL
  , x_return_status          OUT NOCOPY      VARCHAR2
  , x_msg_count              OUT NOCOPY      NUMBER
  , x_msg_data               OUT NOCOPY      VARCHAR2
  , p_task_id                IN              NUMBER
  , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
  , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
  , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
  , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
  , x_res_tbl                OUT NOCOPY      csf_resource_tbl
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_RESOURCES_TO_SCHEDULE(3)';
    l_api_version   CONSTANT NUMBER       := 1.0;

    l_res_qualifiers        resource_qualifier_tbl_type;
    l_assign_resource_tbl   jtf_assign_pub.assignresources_tbl_type;
    j                       PLS_INTEGER;
    k                       PLS_INTEGER;
    --
    CURSOR c_task_info IS
      SELECT source_object_id
           , planned_start_date
           , planned_end_date
           , planned_effort
           , planned_effort_uom
        FROM jtf_tasks_b t
       WHERE t.task_id = p_task_id;
    l_task_info c_task_info%ROWTYPE;
    --
    CURSOR c_resource_info IS
      SELECT /*+ CARDINALITY(tr, 1) */
             r.resource_name
           , t.name terr_name
           , tr.resource_index
        FROM jtf_rs_all_resources_vl r
           , jtf_terr_all t
           , TABLE( CAST( x_res_tbl AS csf_resource_tbl ) ) tr
       WHERE r.resource_id = tr.resource_id
         AND r.resource_type = tr.resource_type
         AND t.terr_id (+) = tr.terr_id;
  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_task_info;
    FETCH c_task_info INTO l_task_info;
    CLOSE c_task_info;

    get_resources_to_schedule(
      p_api_version            => 1
    , p_init_msg_list          => fnd_api.g_false
    , x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_task_id                => p_task_id
    , p_incident_id            => l_task_info.source_object_id
    , p_res_qualifier_tbl      => l_res_qualifiers
    , p_scheduling_mode        => 'X'
    , p_start                  => l_task_info.planned_start_date
    , p_end                    => l_task_info.planned_end_date
    , p_duration               => l_task_info.planned_effort
    , p_duration_uom           => l_task_info.planned_effort_uom
    , p_contracts_flag         => p_contracts_flag
    , p_ib_flag                => p_ib_flag
    , p_territory_flag         => p_territory_flag
    , p_skill_flag             => p_skill_flag
    , x_res_tbl                => l_assign_resource_tbl
    );




    IF x_res_tbl IS NULL THEN
      x_res_tbl := csf_resource_tbl();
    END IF;

    --start with an empty table so that previous value are deleted
    x_res_tbl.delete;

    -- if qualified resoucres are found, add them to the output list
    IF x_return_status = fnd_api.g_ret_sts_success AND l_assign_resource_tbl.COUNT > 0 THEN

      j := l_assign_resource_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
        x_res_tbl.EXTEND;
        k := x_res_tbl.LAST;
        x_res_tbl(k) :=
          csf_resource(
              k
            , l_assign_resource_tbl(j).resource_id
            , l_assign_resource_tbl(j).resource_type
            , NULL
            , l_assign_resource_tbl(j).resource_source
            , l_assign_resource_tbl(j).terr_id
            , l_assign_resource_tbl(j).terr_name
            , l_assign_resource_tbl(j).terr_rank
            , 'N'
            , NULL
            , l_assign_resource_tbl(j).start_date
            , l_assign_resource_tbl(j).end_date
            );

        IF l_assign_resource_tbl(j).terr_rank = jtf_assign_pub.am_miss_num THEN
          x_res_tbl(k).terr_rank := NULL;
        END IF;

        IF l_assign_resource_tbl(j).preference_type = 'I' THEN
          x_res_tbl(k).resource_source := 'IB';
          x_res_tbl(k).preferred_resource_flag := 'Y';
        ELSIF l_assign_resource_tbl(j).preference_type = 'C' THEN
          x_res_tbl(k).resource_source := 'CNT';
          x_res_tbl(k).preferred_resource_flag := 'Y';
        ELSIF l_assign_resource_tbl(j).preference_type = 'SK' THEN
          x_res_tbl(k).resource_source := 'SK';
        ELSIF l_assign_resource_tbl(j).terr_id IS NOT NULL AND l_assign_resource_tbl(j).terr_id <> -1 THEN
          x_res_tbl(k).resource_source := 'TER';
        ELSE
          x_res_tbl(k).resource_source := 'RS';
        END IF;

        j := l_assign_resource_tbl.NEXT(j);
      END LOOP;

      FOR v_resource_info IN c_resource_info LOOP
        x_res_tbl(v_resource_info.resource_index).resource_name := v_resource_info.resource_name;
        x_res_tbl(v_resource_info.resource_index).terr_name     := v_resource_info.terr_name;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_resources_to_schedule;

  FUNCTION get_resources_to_schedule_pvt(
      p_task_id                IN              NUMBER
    , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
    , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
    , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
    , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
    ) RETURN csf_resource_tbl IS
    PRAGMA autonomous_transaction;
    --
    l_return_status        VARCHAR2(1);
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_res_tbl              csf_resource_tbl;
  BEGIN
    get_resources_to_schedule(
        p_api_version          => 1.0
      , p_init_msg_list        => fnd_api.g_true
      , x_return_status        => l_return_status
      , x_msg_count            => l_msg_count
      , x_msg_data             => l_msg_data
      , p_task_id              => p_task_id
      , p_contracts_flag       => p_contracts_flag
      , p_ib_flag              => p_ib_flag
      , p_territory_flag       => p_territory_flag
      , p_skill_flag           => p_skill_flag
      , x_res_tbl              => l_res_tbl
      );

    ROLLBACK;

    RETURN l_res_tbl;
  END get_resources_to_schedule_pvt;

  FUNCTION get_resources_to_schedule(
      p_task_id                IN              NUMBER
    , p_contracts_flag         IN              VARCHAR2               DEFAULT NULL
    , p_ib_flag                IN              VARCHAR2               DEFAULT NULL
    , p_territory_flag         IN              VARCHAR2               DEFAULT NULL
    , p_skill_flag             IN              VARCHAR2               DEFAULT NULL
    )
    RETURN csf_resource_tbl IS
    l_res_tbl              csf_resource_tbl;
  BEGIN
    l_res_tbl :=
      get_resources_to_schedule_pvt(
          p_task_id         => p_task_id
        , p_contracts_flag  => csr_scheduler_pub.get_sch_parameter_value('spPickContractResources')
        , p_ib_flag         => csr_scheduler_pub.get_sch_parameter_value('spPickIbResources')
        , p_territory_flag  => csr_scheduler_pub.get_sch_parameter_value('spPickTerritoryResources')
        , p_skill_flag      => csr_scheduler_pub.get_sch_parameter_value('spPickSkilledResources')
        );

    RETURN l_res_tbl;
  END get_resources_to_schedule;


  /**
   * Returns the Resource Type Code corresponding to a Resource Category.
   * <br>
   * In sync with the code done in JTF_RS_ALL_RESOURCES_VL
   *
   * @param   p_category    Resource Category
   * @returns Resource Type Code (VARCHAR2).
   */
  FUNCTION rs_category_type(p_category VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_category = 'EMPLOYEE' THEN
      RETURN 'RS_EMPLOYEE';
    ELSIF p_category = 'PARTNER' THEN
      RETURN 'RS_PARTNER';
    ELSIF p_category = 'SUPPLIER_CONTACT' THEN
      RETURN 'RS_SUPPLIER';
    ELSIF p_category = 'PARTY' THEN
      RETURN 'RS_PARTY';
    ELSIF p_category = 'OTHER' THEN
      RETURN 'RS_OTHER';
    ELSE
      RETURN NULL;
    END IF;
  END rs_category_type;

  /**
   * Returns the ID of the Resource tied to the given User (FND User).
   * <br>
   * If no User is passed in, then it will take the User who has logged in
   * (FND_GLOBAL.USER_ID).
   *
   * @param   p_user_id   Identifier to the User desired (Optional)
   * @returns Resource ID (NUMBER)
   */
  FUNCTION resource_id(p_user_id NUMBER DEFAULT NULL)
    RETURN NUMBER IS
    CURSOR c_resource IS
      SELECT resource_id
        FROM jtf_rs_resource_extns
       WHERE user_id = NVL(p_user_id, fnd_global.user_id);
    l_id   NUMBER := NULL;
  BEGIN
    OPEN c_resource;
    FETCH c_resource INTO l_id;
    CLOSE c_resource;

    RETURN l_id;
  END resource_id;

  /**
   * Returns the Resource Type of the Resource tied to the given user. (FND User)
   * <br>
   * If no User is passed in, then it will take the User who has logged in
   * (FND_GLOBAL.USER_ID).
   *
   * @param   p_user_id   Identifier to the User desired (Optional)
   * @returns Resource Type (VARCHAR2)
   */
  FUNCTION resource_type(p_user_id NUMBER DEFAULT NULL)
    RETURN VARCHAR2 IS
    CURSOR c_resource_type IS
      SELECT category
        FROM jtf_rs_resource_extns
       WHERE user_id = NVL(p_user_id, fnd_global.user_id);
    l_type   jtf_rs_resource_extns.category%TYPE;
  BEGIN
    OPEN c_resource_type;
    FETCH c_resource_type INTO l_type;
    CLOSE c_resource_type;

    RETURN rs_category_type(l_type);
  END resource_type;

  FUNCTION get_resource_from_cache(
    p_res_id       NUMBER
  , p_res_type     VARCHAR2
  , p_get_address  BOOLEAN   DEFAULT FALSE
  , p_date         DATE      DEFAULT NULL
  )
    RETURN resource_cache_rec_type IS

    l_return_status  VARCHAR2(1);
    l_msg_data       VARCHAR2(2000);
    l_msg_count      NUMBER;
    l_found          BOOLEAN;
    l_res_cache_info resource_cache_rec_type;

    CURSOR c_normal_resource IS
      SELECT resource_id
           , p_res_type resource_type
           , resource_name
           , resource_number
        FROM jtf_rs_resource_extns_vl
       WHERE resource_id = p_res_id;

    CURSOR c_group_resource IS
      SELECT group_id resource_id
           , 'RS_GROUP' resource_type
           , group_name resource_name
           , group_number resource_number
        FROM jtf_rs_groups_vl
       WHERE group_id = p_res_id;

    CURSOR c_team_resource IS
      SELECT team_id resource_id
           , 'RS_TEAM' resource_type
           , team_name resource_name
           , team_number resource_number
        FROM jtf_rs_teams_vl
       WHERE team_id = p_res_id;

    l_resource c_normal_resource%ROWTYPE;
  BEGIN
    IF p_res_id IS NULL OR p_res_type IS NULL THEN
      RETURN NULL;
    END IF;

    -- Check whether the Resource exists in the Cache
    l_found := FALSE;
    IF g_res_info_cache.EXISTS(p_res_id) THEN
      l_res_cache_info := g_res_info_cache(p_res_id);
      l_found          := l_res_cache_info.resource_type = p_res_type;
    END IF;

    IF NOT l_found THEN
      IF p_res_type = 'RS_GROUP' THEN
        OPEN c_group_resource;
        FETCH c_group_resource INTO l_resource;
        CLOSE c_group_resource;
      ELSIF p_res_type = 'RS_TEAM' THEN
        OPEN c_team_resource;
        FETCH c_team_resource INTO l_resource;
        CLOSE c_team_resource;
      ELSE
        OPEN c_normal_resource;
        FETCH c_normal_resource INTO l_resource;
        CLOSE c_normal_resource;
      END IF;

      -- Populate the Resource Cache Record
      l_res_cache_info.resource_id     := l_resource.resource_id;
      l_res_cache_info.resource_type   := l_resource.resource_type;
      l_res_cache_info.resource_name   := l_resource.resource_name;
      l_res_cache_info.resource_number := l_resource.resource_number;
    END IF;

    IF p_get_address THEN
      -- Check the validity of the Address in the Cache for the date
      IF    l_res_cache_info.address.party_site_id IS NULL
         OR TRUNC(p_date) < l_res_cache_info.address.start_date_active
         OR TRUNC(p_date) > NVL(l_res_cache_info.address.end_date_active, p_date + 1)
      THEN
        csf_resource_address_pvt.get_resource_address(
          p_api_version       => 1.0
        , x_return_status     => l_return_status
        , x_msg_count         => l_msg_count
        , x_msg_data          => l_msg_data
        , p_resource_id       => p_res_id
        , p_resource_type     => p_res_type
        , p_date              => p_date
        , p_res_shift_add     => g_res_add_prof
        , x_address_rec       => l_res_cache_info.address
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RETURN NULL;
        END IF;

        l_found := FALSE;
      END IF;
    END IF;

    -- Cache the Resource Information for future use.
    IF NOT l_found THEN
      g_res_info_cache(p_res_id) := l_res_cache_info;
    END IF;

    RETURN l_res_cache_info;
  END get_resource_from_cache;

  /**
   * Returns the Resource Name given the Resource ID and Type.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @returns Resource Name (VARCHAR2)
   */
  FUNCTION get_resource_name(p_res_id NUMBER, p_res_type VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN get_resource_from_cache(p_res_id, p_res_type).resource_name;
  END get_resource_name;

  /**
   * Returns the Complete Resource Information given the Resource ID and Type.
   * The returned record includes Resource Number and Resource Name.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @returns Resource Information filled in RESOURCE_REC_TYPE
   */
  FUNCTION get_resource_info(p_res_id NUMBER, p_res_type VARCHAR2)
    RETURN resource_rec_type IS
    l_res_cache_info  resource_cache_rec_type;
    l_res_info        resource_rec_type;
  BEGIN
    l_res_cache_info := get_resource_from_cache(p_res_id, p_res_type);

    l_res_info.resource_id     := l_res_cache_info.resource_id;
    l_res_info.resource_type   := l_res_cache_info.resource_type;
    l_res_info.resource_name   := l_res_cache_info.resource_name;
    l_res_info.resource_number := l_res_cache_info.resource_number;

    RETURN l_res_info;
  END get_resource_info;

  /**
   * Returns the Address of the Party created for the Resource as of the
   * date passed.
   *
   * @param   p_res_id    Resource ID
   * @param   p_res_type  Resource Type Code
   * @param   p_date      Active Party Site for the given date
   *
   * @returns Party Address of the Resource
   */
  FUNCTION get_resource_party_address (
    p_res_id    NUMBER
  , p_res_type  VARCHAR2
  , p_date      DATE
  , p_res_shift_add VARCHAR2 DEFAULT NULL
  )
    RETURN csf_resource_address_pvt.address_rec_type IS
  BEGIN
   G_RES_ADD_PROF := p_res_shift_add;

    RETURN get_resource_from_cache(p_res_id, p_res_type, TRUE, p_date).address;
  END get_resource_party_address;

  /**
   * Returns the Resource Type Name corresponding to the Resource Type Code
   *
   * @param   p_res_type   Resource Type Code
   * @returns Resource Type Name (VARCHAR2)
   */
  FUNCTION get_resource_type_name(p_res_type VARCHAR2)
    RETURN VARCHAR2 IS
    i      PLS_INTEGER;

    CURSOR c_resource_type_names IS
      SELECT o.object_code code, o.name
        FROM jtf_object_usages u
           , jtf_objects_tl o
       WHERE u.object_user_code = 'RESOURCE_TYPES'
         AND o.object_code = u.object_code
         AND o.language = userenv('LANG');
  BEGIN
    IF g_res_type_name_tbl IS NULL THEN
      g_res_type_name_tbl := res_type_name_tbl_type();
      FOR v_resource_type_name IN c_resource_type_names LOOP
        g_res_type_name_tbl.extend();
        i := g_res_type_name_tbl.LAST;
        g_res_type_name_tbl(i).resource_type_code := v_resource_type_name.code;
        g_res_type_name_tbl(i).resource_type_name := v_resource_type_name.name;
      END LOOP;
    END IF;

    FOR i IN 1..g_res_type_name_tbl.COUNT LOOP
      IF g_res_type_name_tbl(i).resource_type_code = p_res_type THEN
        RETURN g_res_type_name_tbl(i).resource_type_name;
      END IF;
    END LOOP;
    RETURN p_res_type;
  END get_resource_type_name;

  /**
   * Converts the given Time from Resource Timezone to Server Timezone
   * or vice versa.
   * <br>
   * By default, the given date is assumed to be in Resource Timezone and the
   * date returned is Server Timezone. Set p_server_to_resource parameter as
   * 'T' (FND_API.G_TRUE) to make it return the other way round.
   * <br>
   * Note that the API doesnt support RS_TEAM or RS_GROUP resources.
   *
   * @param  p_api_version             API Version (1.0)
   * @param  p_init_msg_list           Initialize Message List
   * @param  x_return_status           Return Status of the Procedure.
   * @param  x_msg_count               Number of Messages in the Stack.
   * @param  x_msg_data                Stack of Error Messages.
   * @param  p_resource_id             Resource ID
   * @param  p_resource_type           Resource Type
   * @param  p_datetime                Date to be converted
   * @param  p_server_to_resource      Server to Resource Timezone
   */
  PROCEDURE convert_timezone(
    p_api_version          IN              NUMBER
  , p_init_msg_list        IN              VARCHAR2
  , x_return_status        OUT    NOCOPY   VARCHAR2
  , x_msg_count            OUT    NOCOPY   NUMBER
  , x_msg_data             OUT    NOCOPY   VARCHAR2
  , p_resource_id          IN              NUMBER
  , p_resource_type        IN              VARCHAR2
  , x_datetime             IN OUT NOCOPY   DATE
  , p_server_to_resource   IN              VARCHAR2
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CONVERT_TIMEZONE';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_source_tz_id           NUMBER;
    l_dest_tz_id             NUMBER;
    l_temp_tz_id             NUMBER;
    CURSOR c_resource IS
      SELECT time_zone
        FROM jtf_rs_resource_extns
       WHERE resource_id = p_resource_id
         AND p_resource_type NOT IN('RS_GROUP', 'RS_TEAM');
  BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, 'CSF_TASKS_PUB') THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Start actual processing
    fnd_profile.get('SERVER_TIMEZONE_ID', l_dest_tz_id);

    OPEN c_resource;
    FETCH c_resource INTO l_source_tz_id;
    CLOSE c_resource;

    -- Reverse conversion when requested
    IF fnd_api.to_boolean(p_server_to_resource) THEN
      l_temp_tz_id   := l_source_tz_id;
      l_source_tz_id := l_dest_tz_id;
      l_dest_tz_id   := l_source_tz_id;
    END IF;

    -- Only try conversion when source and destination timezones are found
    IF l_source_tz_id IS NOT NULL AND l_dest_tz_id IS NOT NULL THEN
      hz_timezone_pub.get_time(
        p_api_version         => 1.0
      , p_init_msg_list       => fnd_api.g_false
      , p_source_tz_id        => l_source_tz_id
      , p_dest_tz_id          => l_dest_tz_id
      , p_source_day_time     => x_datetime
      , x_dest_day_time       => x_datetime
      , x_return_status       => x_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      );
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END convert_timezone;

  /**
   * Gets the Shift Definitions of the given Resource between the two given Dates.
   *
   * CSF has its own "Get Resource Shifts" API in addition to JTF providing it is
   * because CSF is still calling JTF Calendar API rather than JTF Calendar 24 API.
   * Going forward, we should be calling JTF_CALENDAR24_PUB rather than
   * JTF_CALENDAR_PUB.
   * Because of this the following Shift Definition is returned as two Shifts.
   * <br>
   * Shift Construct #101: Start = 1-JAN-2005 18:00:00 to 2-JAN-2005 07:00:00
   *    is returned as
   *       Shift Record #1
   *           Shift Construct = 101
   *           Shift Date      = 1-JAN-2005
   *           Start Time      = 18:00
   *           End Time        = 23:59
   *
   *       Shift Record #2
   *           Shift Construct = 101
   *           Shift Date      = 2-JAN-2005
   *           Start Time      = 00:00
   *           End Time        = 07:00
   * <br>
   * Note that Shift Record#1 and Shift Record#2 are adjacent in the returned
   * Shifts Table. Morever both has the same Shift Construct ID and the difference
   * between End Time of the first record and the start time of the second is
   * One Minute (1/1440 days).
   *
   * This feature is being used by this API to merge those shifts in a single
   * record structure.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_resource_id           Resource Identifier for whom Shifts are required.
   * @param   p_resource_type         Resource Type of the above Resource.
   * @param   p_start_date            Start of the Window between which Shifts are required.
   * @param   p_end_date              End of the Window between which Shifts are required.
   * @param   x_shifts                Shift Definitions
   */
  PROCEDURE get_resource_shifts(
    p_api_version     IN          NUMBER
  , p_init_msg_list   IN          VARCHAR2
  , x_return_status   OUT NOCOPY  VARCHAR2
  , x_msg_count       OUT NOCOPY  NUMBER
  , x_msg_data        OUT NOCOPY  VARCHAR2
  , p_resource_id     IN          NUMBER
  , p_resource_type   IN          VARCHAR2
  , p_start_date      IN          DATE
  , p_end_date        IN          DATE
  , p_shift_type      IN         VARCHAR2 DEFAULT NULL
  , x_shifts          OUT NOCOPY  shift_tbl_type
  ) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_RESOURCE_SHIFTS';
    l_api_version   CONSTANT NUMBER       := 1.0;

    l_multiday_shifts        jtf_calendar_pub.shift_tbl_type;
    l_time                   DATE;
    l_shift_starttime        DATE;
    l_shift_endtime          DATE;
    i                        PLS_INTEGER; -- Iterator for JTF's Shift Table
    j                        PLS_INTEGER; -- Iterator for CSF's Shift Table

  BEGIN
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    jtf_calendar_pub.get_resource_shifts(
      p_api_version       => 1.0
    , p_resource_id       => p_resource_id
    , p_resource_type     => p_resource_type
    , p_start_date        => p_start_date
    , p_end_date          => p_end_date
    , x_return_status     => x_return_status
    , x_msg_count         => x_msg_count
    , x_msg_data          => x_msg_data
    , x_shift             => l_multiday_shifts
    );

    IF x_return_status <> fnd_api.g_ret_sts_success OR l_multiday_shifts.COUNT = 0 THEN
      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;

    i := l_multiday_shifts.FIRST;
    j := 0;
    WHILE i IS NOT NULL LOOP
      l_time            := to_date(l_multiday_shifts(i).start_time, 'HH24:MI');
      l_shift_starttime := l_multiday_shifts(i).shift_date + (l_time - trunc(l_time));
      l_time            := to_date(l_multiday_shifts(i).end_time, 'HH24:MI');
      l_shift_endtime   := l_multiday_shifts(i).shift_date + (l_time - trunc(l_time));



       IF (l_multiday_shifts(i).availability_type = p_shift_type  OR P_SHIFT_TYPE IS NULL) THEN
        -- Check whether the previous shift is same as the current one with a Minute Difference
        IF ( x_shifts.EXISTS(j)
             AND x_shifts(j).shift_construct_id = l_multiday_shifts(i).shift_construct_id
             AND (x_shifts(j).end_datetime + 1/1440) = l_shift_starttime )
        THEN
          -- Its the same shift but crossing the 24 Hour Boundary. Merge them.
          x_shifts(j).end_datetime := l_shift_endtime;
        ELSE
		  IF l_shift_endtime > p_start_date AND l_shift_starttime < p_end_date THEN
          j := j+1;
          x_shifts(j).shift_construct_id := l_multiday_shifts(i).shift_construct_id;
          x_shifts(j).availability_type  := l_multiday_shifts(i).availability_type;
          x_shifts(j).start_datetime     := l_shift_starttime;
          x_shifts(j).end_datetime       := l_shift_endtime;
        END IF;
       END IF;
      END IF;

      i := l_multiday_shifts.NEXT(i);
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_resource_shifts;

  PROCEDURE get_location(
      x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    , x_creation_date             OUT NOCOPY DATE
    , x_feed_time                 OUT NOCOPY DATE
    , x_status_code               OUT NOCOPY VARCHAR2
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_speed                     OUT NOCOPY NUMBER
    , x_direction                 OUT NOCOPY VARCHAR2
    , x_parked_time               OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_device_tag                OUT NOCOPY VARCHAR2
    , x_status_code_meaning       OUT NOCOPY VARCHAR2
    ) IS
    l_address          csf_resource_address_pvt.address_rec_type;
    l_geometry         MDSYS.SDO_GEOMETRY;
    l_res_lat          NUMBER;
    l_res_lon          NUMBER;
    l_valid_geo        VARCHAR2(5);
    l_mapping_count    PLS_INTEGER := 0;
    --
    CURSOR c_status_lookup IS
      SELECT NVL(meaning, 'AT_HOME')
        FROM fnd_lookups
       WHERE lookup_type = 'CSF_GPS_DEVICE_STATUSES'
         AND lookup_code = 'AT_HOME';
    CURSOR c_device_res_map_exists IS
      SELECT count(*)
        FROM csf_gps_device_assignments a
       WHERE a.resource_id = p_resource_id
         AND a.resource_type = p_resource_type
         AND NVL(p_date, SYSDATE) BETWEEN a.start_date_active AND NVL(a.end_date_active, SYSDATE + 1);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN  c_device_res_map_exists;
    FETCH c_device_res_map_exists INTO l_mapping_count;
    CLOSE c_device_res_map_exists;

    IF p_date > SYSDATE OR NVL(csf_gps_pub.is_gps_enabled, 'N') <> 'Y' OR l_mapping_count = 0 THEN
      l_address :=
        get_resource_party_address(
            p_res_id   => p_resource_id
          , p_res_type => p_resource_type
          , p_date     => p_date
          );

      -- This is wrong. It should follow the Country specific Formatting rules
      x_address := l_address.street || ', ' || l_address.city || ', ' || l_address.state || ', ' || l_address.postal_code || ', ' || l_address.country;
      x_status_code := 'AT_HOME';
      x_device_tag :=
        csf_gps_pub.get_gps_label(
            p_resource_id   => p_resource_id
          , p_resource_type => p_resource_type
          , p_date          => p_date
          );
      OPEN c_status_lookup;
      FETCH c_status_lookup INTO x_status_code_meaning;
      CLOSE c_status_lookup;

      -- Fetch the Geometry corresponding to the Address
      IF l_address.geometry IS NOT NULL THEN
        csf_locus_pub.verify_locus(
            p_api_version       => 1.0
          , p_locus             => l_address.geometry
          , x_msg_count         => x_msg_count
          , x_msg_data          => x_msg_data
          , x_return_status     => x_return_status
          , x_result            => l_valid_geo
          );

        IF l_valid_geo = 'TRUE' THEN
          IF l_address.geometry.sdo_elem_info IS NOT NULL
            AND l_address.geometry.sdo_ordinates IS NOT NULL
          THEN
              x_longitude :=  ROUND(l_address.geometry.sdo_ordinates(1), 8);
              x_latitude  :=  ROUND(l_address.geometry.sdo_ordinates(2), 8);
          ELSIF l_address.geometry.sdo_point IS NOT NULL
          THEN
            x_longitude :=  ROUND(l_address.geometry.sdo_point.x, 8);
            x_latitude  :=  ROUND(l_address.geometry.sdo_point.y, 8);
          ELSE
            x_longitude := -9999;
            x_latitude  := -9999;
          END IF;
        ELSE
          x_longitude := -9999;
          x_latitude  := -9999;
        END IF;
      ELSE
        x_longitude := -9999;
        x_latitude  := -9999;
      END IF;
      x_status_code_meaning := NULL;
    ELSE
      csf_gps_pub.get_location(
          p_resource_id         => p_resource_id
        , p_resource_type       => p_resource_type
        , p_date                => p_date
        , x_feed_time           => x_feed_time
        , x_status_code         => x_status_code
        , x_latitude            => x_latitude
        , x_longitude           => x_longitude
        , x_speed               => x_speed
        , x_direction           => x_direction
        , x_parked_time         => x_parked_time
        , x_address             => x_address
        , x_creation_date       => x_creation_date
        , x_device_tag          => x_device_tag
        , x_status_code_meaning => x_status_code_meaning
        );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'GET_LOCATION');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_location;

  PROCEDURE get_location(
      x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_status_meaning            OUT NOCOPY VARCHAR2
    , x_device_tag                OUT NOCOPY VARCHAR2
    ) IS
    l_feed_time            csf_gps_location_feeds.vendor_feed_time%TYPE;
    l_status_code          csf_gps_location_feeds.status%TYPE;
    l_speed                csf_gps_location_feeds.speed%TYPE;
    l_direction            csf_gps_location_feeds.direction%TYPE;
    l_parked_time          csf_gps_location_feeds.parked_time%TYPE;
    l_creation_date        csf_gps_location_feeds.creation_date%TYPE;
  BEGIN
    get_location(
        x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , x_return_status          => x_return_status
      , p_resource_id            => p_resource_id
      , p_resource_type          => p_resource_type
      , p_date                   => p_date
      , x_feed_time              => l_feed_time
      , x_status_code            => l_status_code
      , x_latitude               => x_latitude
      , x_longitude              => x_longitude
      , x_speed                  => l_speed
      , x_direction              => l_direction
      , x_parked_time            => l_parked_time
      , x_address                => x_address
      , x_creation_date          => l_creation_date
      , x_device_tag             => x_device_tag
      , x_status_code_meaning    => x_status_meaning
      );
  END get_location;

  FUNCTION get_location (
      p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE     DEFAULT SYSDATE
    ) RETURN MDSYS.SDO_POINT_TYPE IS
    l_return_status        VARCHAR2(1);
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_feed_time            csf_gps_location_feeds.vendor_feed_time%TYPE;
    l_status_code          csf_gps_location_feeds.status%TYPE;
    l_latitude             csf_gps_location_feeds.latitude%TYPE;
    l_longitude            csf_gps_location_feeds.longitude%TYPE;
    l_speed                csf_gps_location_feeds.speed%TYPE;
    l_direction            csf_gps_location_feeds.direction%TYPE;
    l_parked_time          csf_gps_location_feeds.parked_time%TYPE;
    l_address              csf_gps_location_feeds.address%TYPE;
    l_creation_date        csf_gps_location_feeds.creation_date%TYPE;
    l_device_tag           csf_gps_devices.device_tag%TYPE;
    l_status_code_meaning  fnd_lookups.meaning%TYPE;
  BEGIN
    get_location(
        x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , x_return_status          => l_return_status
      , p_resource_id            => p_resource_id
      , p_resource_type          => p_resource_type
      , p_date                   => p_date
      , x_feed_time              => l_feed_time
      , x_status_code            => l_status_code
      , x_latitude               => l_latitude
      , x_longitude              => l_longitude
      , x_speed                  => l_speed
      , x_direction              => l_direction
      , x_parked_time            => l_parked_time
      , x_address                => l_address
      , x_creation_date          => l_creation_date
      , x_device_tag             => l_device_tag
      , x_status_code_meaning    => l_status_code_meaning
      );
    RETURN MDSYS.SDO_POINT_TYPE(l_longitude, l_latitude, 0);
  END get_location;

  FUNCTION get_location_attributes(
      p_resource_id                IN        NUMBER
    , p_resource_type              IN        VARCHAR2
    , p_date                       IN        DATE      DEFAULT SYSDATE
    )
    RETURN VARCHAR2 IS
    l_return_status        VARCHAR2(1);
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_feed_time            csf_gps_location_feeds.vendor_feed_time%TYPE;
    l_status_code          csf_gps_location_feeds.status%TYPE;
    l_latitude             csf_gps_location_feeds.latitude%TYPE;
    l_longitude            csf_gps_location_feeds.longitude%TYPE;
    l_speed                csf_gps_location_feeds.speed%TYPE;
    l_direction            csf_gps_location_feeds.direction%TYPE;
    l_parked_time          csf_gps_location_feeds.parked_time%TYPE;
    l_address              csf_gps_location_feeds.address%TYPE;
    l_creation_date        csf_gps_location_feeds.creation_date%TYPE;
    l_device_tag           csf_gps_devices.device_tag%TYPE;
    l_status_code_meaning  fnd_lookups.meaning%TYPE;
  BEGIN
    get_location(
        x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , x_return_status          => l_return_status
      , p_resource_id            => p_resource_id
      , p_resource_type          => p_resource_type
      , p_date                   => p_date
      , x_feed_time              => l_feed_time
      , x_status_code            => l_status_code
      , x_latitude               => l_latitude
      , x_longitude              => l_longitude
      , x_speed                  => l_speed
      , x_direction              => l_direction
      , x_parked_time            => l_parked_time
      , x_address                => l_address
      , x_creation_date          => l_creation_date
      , x_device_tag             => l_device_tag
      , x_status_code_meaning    => l_status_code_meaning
      );

    RETURN l_feed_time || '@@'
        || l_status_code || '@@'
        || l_latitude || '@@'
        || l_longitude || '@@'
        || l_speed || '@@'
        || l_direction || '@@'
        || l_parked_time || '@@'
        || l_address || '@@'
        || l_creation_date || '@@'
        || l_device_tag || '@@'
        || l_status_code_meaning || '@@' ||'END';
  END get_location_attributes;

  FUNCTION geo_distance(p_lon1 NUMBER, p_lat1 NUMBER, p_lon2 NUMBER, p_lat2 NUMBER)
    RETURN NUMBER IS
    l_north     NUMBER;
    l_east      NUMBER;
  BEGIN
    l_north := ( (p_lat2*g_pi/180.0) - (p_lat1*g_pi/180.0) ) * g_earth_radius;
    l_east  := ( ( (p_lon2*g_pi/180.0) -(p_lon1*g_pi/180.0) ) * COS(p_lat2* g_pi/180.0) )
              * g_earth_radius;
    RETURN SQRT ( (l_north * l_north) + (l_east * l_east) );
  END geo_distance;

  FUNCTION get_third_party_role(
     p_resource_id        IN              NUMBER
   , p_resource_type      IN              VARCHAR2
   ) RETURN VARCHAR2 IS

  CURSOR c_roles IS
  SELECT jrb.role_code
       , jrr.role_resource_type
   FROM  jtf_rs_role_relations jrr
       , jtf_rs_roles_b jrb
   WHERE jrr.role_id = jrb.role_id
     AND jrr.role_resource_id = p_resource_id
     AND jrb.role_type_code = 'CSF_THIRD_PARTY'
     AND jrr.role_resource_type = p_resource_type
     AND ( jrr.start_date_active IS NULL or trunc(jrr.start_date_active) <= sysdate )
     AND ( jrr.end_date_active IS NULL or trunc(jrr.end_date_active) >= sysdate )
     AND NVL( jrr.delete_flag, 'N') = 'N'
  ORDER BY 1;

    l_role VARCHAR2(30) := NULL;
    l_type VARCHAR2(30) := NULL;

  BEGIN
    IF ( p_resource_id IS NOT NULL and p_resource_type IS NOT NULL ) THEN
      OPEN c_roles;
      LOOP
        FETCH c_roles INTO l_role, l_type;
        EXIT WHEN c_roles%NOTFOUND;
        -- A Group Resource with TPS is eligible for third party scheduling
        -- Any other type of resource with TPS is considered as Internal Resource
        IF l_role = 'CSF_THIRD_PARTY_SERVICE_PROVID' AND l_type = 'RS_GROUP'
        THEN
          RETURN l_role;
        END IF;
        IF l_role = 'CSF_THIRD_PARTY_TECHNICIAN'
        THEN
           RETURN l_role;
        END IF;
      END LOOP;
      RETURN l_role;
    END IF;
    RETURN NULL;
  END get_third_party_role;

BEGIN
  init_assign_errors;
END csf_resource_pub;

/
