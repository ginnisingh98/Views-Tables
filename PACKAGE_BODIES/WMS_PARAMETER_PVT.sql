--------------------------------------------------------
--  DDL for Package Body WMS_PARAMETER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PARAMETER_PVT" AS
  /* $Header: WMSVPPPB.pls 120.7 2008/01/15 08:47:55 kkesavar ship $ */
  -- File        : WMSVPPPS.pls
  -- Content     : WMS_Parameter_PVT package specification
  -- Description : WMS parameters private APIs
  --               This package contains two types of functions:
  --               1. functions related to flexfield
  --               2. functions related to various quantity functions
  --
  -- Notes       :
  -- Modified    : 02/08/99 mzeckzer created
  --               05/01/99 bitang changed the code to call AOL APIs for
  --                        flexfield functions
  --               11/08/99 bitang moved to wms and added comment
  --
  -- Package global variable to store the package name
  g_pkg_name  CONSTANT VARCHAR2(30)          := 'WMS_Parameter_PVT';

  --
  TYPE t_num_empty_loc_rec IS RECORD(
    subinventory_code             VARCHAR2(10)
  , num_empty_locators            NUMBER);

  TYPE t_num_empty_loc_table IS TABLE OF t_num_empty_loc_rec
    INDEX BY BINARY_INTEGER;

  --used in GetNumEmptyLocators
  g_num_empty_locators t_num_empty_loc_table;
  --used in GetPOHeaderLineID
  g_po_header_id NUMBER;
  g_po_line_id NUMBER;
  g_po_reference_id   NUMBER;  -- Bug #4554344

  -- To improve performance in the functions within this package the last set of
  -- in parameters and the return value is cached. In most cases these functions
  -- are called in a Where clause and many times the same parameters are passed
  -- repeatidly. This caching will avoid redoing the work.
  -- Function getsoheader_line
  g_gsohl_header_id      NUMBER;
  g_gsohl_line_id        NUMBER;
  g_gsohl_mo_line_id     NUMBER;
  g_gsohl_reference_id   NUMBER;


g_project_name   VARCHAR2(30); -- Cached project name
g_project_number VARCHAR2(30); -- Cached project number
g_planning_group VARCHAR2(30); -- Cached project group
g_inventory_organization_id  number ;
g_project_id                 number ;

PROCEDURE log_mesg(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN

  l_module := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label
;
  inv_log_util.trace(p_message, l_module, 9);
END log_mesg;


  -- API name    : ClearCache
  -- Type        : Private
  -- Function    : Clears the global cache used in the parameters file.
  --               This will be called from the WMS_RULE_PVT package.
  PROCEDURE clearcache IS
  BEGIN
    g_num_empty_locators.DELETE;
    g_po_header_id := NULL;
    g_po_line_id := NULL;

  END clearcache;

/*LPN Status Project*/
FUNCTION GET_MATERIAL_STATUS(
           	p_status_id                IN NUMBER DEFAULT NULL)
           RETURN VARCHAR2 IS

           l_material_status VARCHAR2(30) :=  NULL;

          BEGIN

           SELECT  status_code into l_material_status
           FROM mtl_material_statuses_vl
           WHERE status_id= p_status_id  ;

           RETURN    l_material_status;

          EXCEPTION

         WHEN OTHERS THEN
              RETURN  NULL;

END GET_MATERIAL_STATUS;
/*LPN Status Project*/


  -- Functions Related To Flexfield
  --
  -- Description
  --   Procedure that returns information about key flexfield
  PROCEDURE get_key_flex_info(
    p_application_short_name IN           VARCHAR2
  , p_flexfield_name         IN           VARCHAR2
  , p_column_name            IN           VARCHAR2
  , x_if_flex_then_available OUT  NOCOPY  VARCHAR2
  , x_flex_data_type_code    OUT  NOCOPY  NUMBER
  , x_flex_name              OUT  NOCOPY  VARCHAR2
  , x_flex_description       OUT  NOCOPY  VARCHAR2
  ) IS
    l_flexfield      fnd_flex_key_api.flexfield_type;
    l_segment        fnd_flex_key_api.segment_type;
    l_nstructures    NUMBER;
    l_structure      fnd_flex_key_api.structure_type;
    l_structure_list fnd_flex_key_api.structure_list;
    l_valueset_dr    fnd_vset.valueset_dr;
    l_valueset_r     fnd_vset.valueset_r;
    l_segment_found  BOOLEAN                         := FALSE;
    l_nsegment       NUMBER;
    l_segment_list   fnd_flex_key_api.segment_list;
  BEGIN
    -- initialize
    x_if_flex_then_available  := 'Y';
    x_flex_data_type_code     := NULL;
    x_flex_name               := NULL;
    x_flex_description        := NULL;
    --
    fnd_flex_key_api.set_session_mode('seed_data');
    --
    l_flexfield               := fnd_flex_key_api.find_flexfield(p_application_short_name, p_flexfield_name);

    --
    IF l_flexfield.instantiated = 'N' THEN
      RETURN;
    END IF;

    -- since we have no info about the structure we would look at
    -- all structures
    fnd_flex_key_api.get_structures(
      flexfield                    => l_flexfield
    , enabled_only                 => TRUE
    , nstructures                  => l_nstructures
    , structures                   => l_structure_list
    );

    FOR l_index IN 1 .. l_nstructures LOOP
      -- find the structure
      l_structure  := fnd_flex_key_api.find_structure(flexfield => l_flexfield, structure_number => l_structure_list(l_index));

      -- find the segment. only consider the ones freezed
      IF  l_structure.instantiated = 'Y'
          AND l_structure.freeze_flag = 'Y' THEN
        fnd_flex_key_api.get_segments(l_flexfield, l_structure, TRUE, l_nsegment, l_segment_list);

        FOR l_seg_index IN 1 .. l_nsegment LOOP
          l_segment  := fnd_flex_key_api.find_segment(l_flexfield, l_structure, l_segment_list(l_seg_index));

          IF l_segment.column_name = p_column_name THEN
            l_segment_found  := TRUE;
            EXIT;
          END IF;
        END LOOP;

        IF  l_segment_found
            AND l_segment.instantiated = 'Y' THEN
          EXIT;
        END IF;
      END IF;
    END LOOP;

    --
    -- segment not found
    IF l_segment_found = FALSE
       OR l_segment.instantiated = 'N' THEN
      x_if_flex_then_available  := 'N';
      RETURN;
    END IF;

    -- segment found
    -- if the segment does not use a value set, no type info
    IF l_segment.value_set_id IS NULL THEN
      x_flex_data_type_code  := NULL;
    ELSE
      fnd_vset.get_valueset(valueset_id => l_segment.value_set_id, valueset => l_valueset_r, format => l_valueset_dr);

      --
      IF l_valueset_dr.format_type = 'N' THEN -- number type
        x_flex_data_type_code  := 1;
      ELSIF l_valueset_dr.format_type = 'C' THEN -- character type
        x_flex_data_type_code  := 2;
      ELSIF l_valueset_dr.format_type = 'D' THEN -- date type
        x_flex_data_type_code  := 3;
      ELSE
        x_flex_data_type_code  := NULL;  /* should consider more type later */
      END IF;
    END IF;

    --
    x_flex_name               := l_segment.window_prompt;
    x_flex_description        := l_segment.description;
    --
    RETURN;
  --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_if_flex_then_available  := 'Y';
      x_flex_data_type_code     := NULL;
      x_flex_name               := NULL;
      x_flex_description        := NULL;
      RETURN;
  END get_key_flex_info;

  --
  -- Description
  --   Procedure that returns information about descriptive flexfield
  PROCEDURE get_desc_flex_info(
    p_application_short_name IN          VARCHAR2
  , p_flexfield_name         IN          VARCHAR2
  , p_column_name            IN          VARCHAR2
  , x_if_flex_then_available OUT  NOCOPY VARCHAR2
  , x_flex_data_type_code    OUT  NOCOPY NUMBER
  , x_flex_name              OUT  NOCOPY VARCHAR2
  , x_flex_description       OUT  NOCOPY VARCHAR2
  ) IS
    l_flexfield          fnd_dflex.dflex_r;
    l_flexinfo           fnd_dflex.dflex_dr;
    l_contexts           fnd_dflex.contexts_dr;
    l_context            fnd_dflex.context_r;
    l_segments           fnd_dflex.segments_dr;
    l_segment_index      BINARY_INTEGER;
    l_context_index      BINARY_INTEGER;
    l_global_context_idx BINARY_INTEGER;
    l_valueset_dr        fnd_vset.valueset_dr;
    l_valueset_r         fnd_vset.valueset_r;
  BEGIN
    -- initialize
    x_flex_data_type_code     := NULL;
    x_flex_name               := NULL;
    x_flex_description        := NULL;

    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('Get_desc_flex_info(): ');
      inv_pp_debug.send_message_to_pipe('p_flexfield_name: '|| p_flexfield_name);
      inv_pp_debug.send_message_to_pipe('p_column_name: '|| p_column_name);
      inv_pp_debug.send_message_to_pipe('x_if_flex_then_available: '|| x_if_flex_then_available);
    END IF;

    --
    fnd_dflex.get_flexfield(
      appl_short_name              => p_application_short_name
    , flexfield_name               => p_flexfield_name
    , flexfield                    => l_flexfield
    , flexinfo                     => l_flexinfo
    );
    --
    fnd_dflex.get_contexts(flexfield => l_flexfield, contexts => l_contexts);
    --
    -- we only want the global and enabled context
    l_global_context_idx      := l_contexts.global_context;

    -- global context not found
    IF l_global_context_idx = 0
       OR l_global_context_idx IS NULL THEN
      RETURN;
    END IF;

    --
    x_if_flex_then_available  := 'Y';
    --
    -- assemble the context_r record
    l_context.context_code    := l_contexts.context_code(l_global_context_idx);
    l_context.flexfield       := l_flexfield;
    --
    -- get segments
    fnd_dflex.get_segments(l_context, l_segments, TRUE);
    --
    l_segment_index           := 0;

    FOR l_index IN 1 .. l_segments.nsegments LOOP
      IF l_segments.application_column_name(l_index) = p_column_name THEN
        l_segment_index  := l_index;
        EXIT;
      END IF;
    END LOOP;

    --
    IF l_segment_index = 0 THEN
      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe('No segment found in Global context. ncontexts enabled :  '|| l_contexts.ncontexts);
      END IF;

        --segment not found
      /*Start of New proposed fix*/
      FOR l_seg IN 1 .. l_contexts.ncontexts LOOP
        inv_pp_debug.send_message_to_pipe('l_seg : '|| l_seg);

        IF  l_contexts.is_enabled(l_seg) = TRUE
            AND l_seg <> l_contexts.global_context THEN
          inv_pp_debug.send_message_to_pipe('context ENABLED and not GLOBAL');
          l_context.context_code  := l_contexts.context_code(l_seg);
          l_context.flexfield     := l_flexfield;
          fnd_dflex.get_segments(l_context, l_segments, TRUE);

          FOR l_index IN 1 .. l_segments.nsegments LOOP
            IF l_segments.application_column_name(l_index) = p_column_name THEN
              l_segment_index  := l_index;

              IF inv_pp_debug.is_debug_mode THEN
                inv_pp_debug.send_message_to_pipe('Found context code:'|| l_context.context_code);
              END IF;

              RETURN;
            END IF;
          END LOOP;
        END IF;

        inv_pp_debug.send_message_to_pipe('AFTER LOOP: l_segment_index :'|| l_segment_index);
      END LOOP;
    END IF;

    IF l_segment_index = 0 THEN
      x_if_flex_then_available  := 'N';
      RETURN;
    END IF;

    /*End of Proposed fix*/
    inv_pp_debug.send_message_to_pipe('segment found .');

    --
    -- segment found
    -- if the segment does not use a value set, no type info
    IF l_segments.value_set(l_segment_index) IS NULL THEN
      x_flex_data_type_code  := NULL;
    ELSE
      fnd_vset.get_valueset(valueset_id => l_segments.value_set(l_segment_index), valueset => l_valueset_r, format => l_valueset_dr);

      IF l_valueset_dr.format_type = 'N' THEN -- number type
        x_flex_data_type_code  := 1;
      ELSIF l_valueset_dr.format_type = 'C' THEN -- character type
        x_flex_data_type_code  := 2;
      ELSIF l_valueset_dr.format_type = 'D' THEN -- date type
        x_flex_data_type_code  := 3;
      ELSE
        x_flex_data_type_code  := NULL;  /* should consider more type later */
      END IF;
    END IF;

    --
    x_flex_name               := l_segments.row_prompt(l_segment_index);
    x_flex_description        := l_segments.description(l_segment_index);
    --
    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_if_flex_then_available  := 'Y';
      x_flex_data_type_code     := NULL;
      x_flex_name               := NULL;
      x_flex_description        := NULL;

      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe('EXCEPTION: x_if_flex_then_available: '|| x_if_flex_then_available);
      END IF;

      RETURN;
  END get_desc_flex_info;

  --
  -- Description
  --   Returns the application short name for the given application id
  FUNCTION get_application_short_name(p_application_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_appl_short_name VARCHAR2(50);

    --
    CURSOR l_cursor IS
      SELECT application_short_name
        FROM fnd_application
       WHERE application_id = p_application_id;
  BEGIN
    OPEN l_cursor;
    FETCH l_cursor INTO l_appl_short_name;

    IF l_cursor%NOTFOUND THEN
      l_appl_short_name  := NULL;
    END IF;

    RETURN l_appl_short_name;
  END get_application_short_name;

  --
  -- Description
  --   Returns flexfield information
  --   This procedure calls either get_key_flex_info or get_desc_flex_info
  --   based on p_flexfield_usage_code.
  PROCEDURE get_flex_info(
    p_db_object_ref_type_code  IN     NUMBER
  , p_parameter_type_code      IN     NUMBER
  , p_flexfield_usage_code     IN     VARCHAR2
  , p_flexfield_application_id IN     NUMBER
  , p_flexfield_name           IN     VARCHAR2
  , p_column_name              IN     VARCHAR2
  , x_if_flex_then_available   OUT    NOCOPY VARCHAR2
  , x_flex_data_type_code      OUT    NOCOPY NUMBER
  , x_flex_name                OUT    NOCOPY VARCHAR2
  , x_flex_description         OUT    NOCOPY VARCHAR2
  ) IS
    l_appl_short_name VARCHAR2(3);
    l_msg_data        VARCHAR2(256);
    l_msg_count       NUMBER;
  BEGIN
    -- initialize
    x_if_flex_then_available  := NULL;
    x_flex_data_type_code     := NULL;
    x_flex_name               := NULL;
    x_flex_description        := NULL;

    --
    -- validate input

    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('Get_flex_info(): ');
      inv_pp_debug.send_message_to_pipe('p_db_object_ref_type_code: '|| p_db_object_ref_type_code);
      inv_pp_debug.send_message_to_pipe('p_parameter_type_code: '|| p_parameter_type_code);
      inv_pp_debug.send_message_to_pipe('p_flexfield_usage_code: '|| p_flexfield_usage_code);
      inv_pp_debug.send_message_to_pipe('p_flexfield_name: '|| p_flexfield_name);
      inv_pp_debug.send_message_to_pipe('p_column_name: '|| p_column_name);
      inv_pp_debug.send_message_to_pipe('x_if_flex_then_available: '|| x_if_flex_then_available);
    END IF;

    IF p_db_object_ref_type_code = g_miss_num
       OR p_db_object_ref_type_code IS NULL
       OR p_parameter_type_code = g_miss_num
       OR p_parameter_type_code IS NULL
       OR p_flexfield_usage_code = g_miss_char
       OR p_flexfield_application_id = g_miss_num
       OR p_flexfield_name = g_miss_char
       OR p_column_name = g_miss_char THEN
      inv_pp_debug.send_message_to_pipe('Failed input validation .RETURN');
      RETURN;
    END IF;

    --
    x_if_flex_then_available  := 'Y';

    IF p_db_object_ref_type_code <> 1 THEN  /* not a single referenced object */
      RETURN;
    END IF;

    --
    IF p_parameter_type_code <> 1 THEN  /* self-defined sql expression */
      RETURN;
    END IF;

    --
    IF p_flexfield_application_id IS NULL THEN
      inv_pp_debug.send_message_to_pipe('p_flexfield_application_id IS NULL.RETURN');

      IF (p_flexfield_usage_code IS NOT NULL) THEN
        x_if_flex_then_available  := 'N';
      END IF;

      RETURN;
    END IF;

    --
    -- everything else should be a column of a table or view, so the
    -- usage code decides whether or not the column could be setup
    -- as flexfield segment.
    --
    l_appl_short_name         := get_application_short_name(p_flexfield_application_id);
    --
    inv_pp_debug.send_message_to_pipe('l_appl_short_name : '|| l_appl_short_name);

    IF l_appl_short_name IS NULL THEN
      fnd_message.set_name('INV', 'INV_INVALID_APPLICATION_ID');
      fnd_message.set_token('APPLICATION_ID', p_flexfield_application_id);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    IF p_flexfield_usage_code = 'K' THEN
      get_key_flex_info(
        p_application_short_name     => l_appl_short_name
      , p_flexfield_name             => p_flexfield_name
      , p_column_name                => p_column_name
      , x_if_flex_then_available     => x_if_flex_then_available
      , x_flex_data_type_code        => x_flex_data_type_code
      , x_flex_name                  => x_flex_name
      , x_flex_description           => x_flex_description
      );
    ELSIF p_flexfield_usage_code = 'D' THEN
      get_desc_flex_info(
        p_application_short_name     => l_appl_short_name
      , p_flexfield_name             => p_flexfield_name
      , p_column_name                => p_column_name
      , x_if_flex_then_available     => x_if_flex_then_available
      , x_flex_data_type_code        => x_flex_data_type_code
      , x_flex_name                  => x_flex_name
      , x_flex_description           => x_flex_description
      );
    ELSE
      -- column can serve as neither key or descriptive flex field
      -- segment so we should just return the following values
      x_if_flex_then_available  := 'Y';
      x_flex_data_type_code     := NULL;
      x_flex_name               := NULL;
      x_flex_description        := NULL;
      inv_pp_debug.send_message_to_pipe('flexfield usage code NULL: '|| ' x_if_flex_then_available: ' || x_if_flex_then_available);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      inv_pp_debug.send_message_to_pipe('EXCEPTION  ');
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
  END get_flex_info;

  -- API name    : IfFlexThenAvailable
  -- Type        : Private
  -- Function    : Returns 'N' if actual parameter is a key or descriptive
  --               flexfield segment and not configured yet, returns 'Y' in
  --               any other case.
  --               ( Needed for all forms base views and LOV's regarding
  --               parameters like rules, restrictions and sort criteria )
  --
  -- Input Parameters  :
  --   See the definition of corresponding column in WMS_PARAMETERS for
  --   update-to-date information about the following input parameters.
  --
  --   p_db_object_ref_type_code:
  --     1 - single referenced ; 2 - multiple referenced
  --   p_parameter_type_code:
  --     1 - column ; 2 - expression
  --   p_flexfield_usage_code:
  --     'K' - key flexfield; 'D' - descriptive flexfield ;
  --     null - not used in flexfield
  --   p_flexfield_application_id:
  --     id of the application in which the flexfield is defined
  --   p_flexfield_name:
  --     code of the key flexfield or name of the descriptive flexfield
  --   p_column_name:
  --     column name if the parameter is based on a table/view column
  --
  -- Notes       : works for global segments only, not for context segments
  --
  FUNCTION ifflexthenavailable(
    p_db_object_ref_type_code  IN NUMBER DEFAULT g_miss_num
  , p_parameter_type_code      IN NUMBER DEFAULT g_miss_num
  , p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
  , p_flexfield_application_id IN NUMBER DEFAULT g_miss_num
  , p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
  , p_column_name              IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN VARCHAR2 IS
    l_if_flex_then_available VARCHAR2(1);
    l_flex_data_type_code    wms_parameters_b.data_type_code%TYPE;
    l_flex_name              wms_parameters_vl.NAME%TYPE;
    l_flex_description       wms_parameters_vl.description%TYPE;
  BEGIN
    get_flex_info(
      p_db_object_ref_type_code    => p_db_object_ref_type_code
    , p_parameter_type_code        => p_parameter_type_code
    , p_flexfield_usage_code       => p_flexfield_usage_code
    , p_flexfield_application_id   => p_flexfield_application_id
    , p_flexfield_name             => p_flexfield_name
    , p_column_name                => p_column_name
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );
    --
    RETURN l_if_flex_then_available;
  END ifflexthenavailable;

  --
  --
  -- API name    : GetFlexDataTypeCode
  -- Type        : Private
  -- Function    : Returns user-defined segment data type if actual parameter is
  --               a key or descriptive flexfield segment and configured,
  --               returns original data type in any other case.
  --               ( Needed for all forms base views and LOV's regarding
  --               parameters like rules, restrictions and sort criteria )
  -- Input Parameters  :
  --   p_data_type_code:
  --     data type of the flexfield segment
  --     1 - number ; 2 - character; 3 - date ; null - not given
  --
  --   See the comment in function IfFlexThenAvailable for the
  --   meaning of the following input parameters.
  --
  --   p_db_object_ref_type_code
  --   p_parameter_type_code
  --   p_flexfield_usage_code
  --   p_flexfield_application_id
  --   p_flexfield_name
  --   p_column_name
  --
  -- Notes       : works for global segments only, not for context segments
  FUNCTION getflexdatatypecode(
    p_data_type_code           IN NUMBER DEFAULT g_miss_num
  , p_db_object_ref_type_code  IN NUMBER DEFAULT g_miss_num
  , p_parameter_type_code      IN NUMBER DEFAULT g_miss_num
  , p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
  , p_flexfield_application_id IN NUMBER DEFAULT g_miss_num
  , p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
  , p_column_name              IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_if_flex_then_available VARCHAR2(1);
    l_flex_data_type_code    wms_parameters_b.data_type_code%TYPE;
    l_flex_name              wms_parameters_vl.NAME%TYPE;
    l_flex_description       wms_parameters_vl.description%TYPE;
    l_appl_short_name        VARCHAR2(3);
  BEGIN
    get_flex_info(
      p_db_object_ref_type_code    => p_db_object_ref_type_code
    , p_parameter_type_code        => p_parameter_type_code
    , p_flexfield_usage_code       => p_flexfield_usage_code
    , p_flexfield_application_id   => p_flexfield_application_id
    , p_flexfield_name             => p_flexfield_name
    , p_column_name                => p_column_name
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );

    --
    IF l_flex_data_type_code IS NOT NULL THEN
      RETURN l_flex_data_type_code;
    ELSE
      RETURN p_data_type_code;
    END IF;
  END getflexdatatypecode;

  --
  -- API name    : GetFlexName
  -- Type        : Private
  -- Function    : Returns user-defined segment name if actual parameter is
  --               a key or descriptive flexfield segment and configured,
  --               returns original name in any other case.
  --               ( Needed for all forms base views and LOV's regarding
  --               parameters like rules, restrictions and sort criteria )
  --
  -- Input Parameters  :
  --   p_name:
  --     name of the flexfield segment
  --
  --   See the comment in function IfFlexThenAvailable for the
  --   meaning of the following input parameters.
  --
  --   p_db_object_ref_type_code
  --   p_parameter_type_code
  --   p_flexfield_usage_code
  --   p_flexfield_application_id
  --   p_flexfield_name
  --   p_column_name
  --
  -- Notes       : works for global segments only, not for context segments
  --
  FUNCTION getflexname(
    p_name                     IN VARCHAR2 DEFAULT g_miss_char
  , p_db_object_ref_type_code  IN NUMBER DEFAULT g_miss_num
  , p_parameter_type_code      IN NUMBER DEFAULT g_miss_num
  , p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
  , p_flexfield_application_id IN NUMBER DEFAULT g_miss_num
  , p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
  , p_column_name              IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN VARCHAR2 IS
    l_if_flex_then_available VARCHAR2(1);
    l_flex_data_type_code    wms_parameters_b.data_type_code%TYPE;
    l_flex_name              wms_parameters_vl.NAME%TYPE;
    l_flex_description       wms_parameters_vl.description%TYPE;
    l_appl_short_name        VARCHAR2(3);
  BEGIN
    get_flex_info(
      p_db_object_ref_type_code    => p_db_object_ref_type_code
    , p_parameter_type_code        => p_parameter_type_code
    , p_flexfield_usage_code       => p_flexfield_usage_code
    , p_flexfield_application_id   => p_flexfield_application_id
    , p_flexfield_name             => p_flexfield_name
    , p_column_name                => p_column_name
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );

    --
    IF l_flex_name IS NOT NULL THEN
      RETURN l_flex_name;
    ELSE
      RETURN p_name;
    END IF;
  END getflexname;

  --
  -- API name    : GetFlexDescription
  -- Type        : Private
  -- Function    : Returns user-defined segment description if actual parameter
  --               is a key or descriptive flexfield segment and configured,
  --               returns original description in any other case.
  --               ( Needed for all forms base views and LOV's regarding
  --               parameters like rules, restrictions and sort criteria )
  --
  -- Input Parameters:
  --   p_description:
  --     description of the flexfield segment
  --   p_db_object_ref_type_code
  --   p_parameter_type_code
  --   p_flexfield_usage_code
  --   p_flexfield_application_id
  --   p_flexfield_name
  --   p_column_name
  --
  -- Notes       : works for global segments only, not for context segments
  FUNCTION getflexdescription(
    p_description              IN VARCHAR2 DEFAULT g_miss_char
  , p_db_object_ref_type_code  IN NUMBER DEFAULT g_miss_num
  , p_parameter_type_code      IN NUMBER DEFAULT g_miss_num
  , p_flexfield_usage_code     IN VARCHAR2 DEFAULT g_miss_char
  , p_flexfield_application_id IN NUMBER DEFAULT g_miss_num
  , p_flexfield_name           IN VARCHAR2 DEFAULT g_miss_char
  , p_column_name              IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN VARCHAR2 IS
    l_if_flex_then_available VARCHAR2(1);
    l_flex_data_type_code    wms_parameters_b.data_type_code%TYPE;
    l_flex_name              wms_parameters_vl.NAME%TYPE;
    l_flex_description       wms_parameters_vl.description%TYPE;
    l_appl_short_name        VARCHAR2(3);
  BEGIN
    get_flex_info(
      p_db_object_ref_type_code    => p_db_object_ref_type_code
    , p_parameter_type_code        => p_parameter_type_code
    , p_flexfield_usage_code       => p_flexfield_usage_code
    , p_flexfield_application_id   => p_flexfield_application_id
    , p_flexfield_name             => p_flexfield_name
    , p_column_name                => p_column_name
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );

    --
    IF l_flex_description IS NOT NULL THEN
      RETURN l_flex_description;
    ELSE
      RETURN p_description;
    END IF;
  END getflexdescription;

  --
  -- Description
  --   testing procedure
  PROCEDURE test IS
    l_flex_data_type_code    wms_parameters_b.data_type_code%TYPE;
    l_if_flex_then_available VARCHAR2(1);
    l_flex_name              wms_parameters_tl.NAME%TYPE;
    l_flex_description       wms_parameters_tl.description%TYPE;
  BEGIN
    get_flex_info(
      p_db_object_ref_type_code    => 2
    , p_parameter_type_code        => 1
    , p_flexfield_usage_code       => 'D'
    , p_flexfield_application_id   => 401
    , p_flexfield_name             => 'MTL_GENERIC_DISPOSITIONS'
    , p_column_name                => 'ATTRIBUTE1'
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );
    get_flex_info(
      p_db_object_ref_type_code    => TO_NUMBER(1)
    , p_flexfield_usage_code       => 'K'
    , p_flexfield_application_id   => 401
    , p_parameter_type_code        => 1
    , p_flexfield_name             => 'MSTK'
    , p_column_name                => 'Item Number Value'
    , x_if_flex_then_available     => l_if_flex_then_available
    , x_flex_data_type_code        => l_flex_data_type_code
    , x_flex_name                  => l_flex_name
    , x_flex_description           => l_flex_description
    );
  END test;

  --
  -- API name    : RoundUp
  -- Type        : Private
  -- Function    : Returns quantity, rounded up according actual and base units
  --               of measure and the conversion defined between them.
  --               ( Used for capacity and on-hand calculation parameters )
  FUNCTION roundup(
    p_quantity          IN NUMBER DEFAULT g_miss_num
  , p_transaction_uom   IN VARCHAR2 DEFAULT g_miss_char
  , p_inventory_item_id IN NUMBER DEFAULT g_miss_num
  , p_base_uom          IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_quantity NUMBER;
  BEGIN
    -- validate input parameters
    IF p_quantity = g_miss_num
       OR p_quantity IS NULL
       OR p_transaction_uom = g_miss_char
       OR p_transaction_uom IS NULL
       OR p_inventory_item_id = g_miss_num
       OR p_inventory_item_id IS NULL
       OR p_base_uom = g_miss_char
       OR p_base_uom IS NULL THEN
      RETURN NULL;
    END IF;

    --
    -- standard way of rounding capacity:
    -- convert capacity to base uom
    -- round up
    -- ( convert back to transaction uom )
    IF p_transaction_uom <> p_base_uom THEN
      l_quantity  := inv_convert.inv_um_convert(
                       p_inventory_item_id
                     , NULL
                     , CEIL(inv_convert.inv_um_convert(p_inventory_item_id, NULL, p_quantity, p_transaction_uom, p_base_uom, NULL, NULL))
                     , p_base_uom
                     , p_transaction_uom
                     , NULL
                     , NULL
                     );
    ELSE
      l_quantity  := CEIL(p_quantity);
    END IF;

    --
    IF l_quantity <= 0 THEN -- can happen, if conversion isn't defined
      RETURN 0;
    END IF;

    --
    RETURN l_quantity;
  --
  END roundup;

  --
  -- API name    : RoundDown
  -- Type        : Private
  -- Function    : Returns quantity, rounded down according actual and base
  --               units of measure and the conversion defined between them.
  --               ( Used for capacity and on-hand calculation parameters )
  FUNCTION rounddown(
    p_quantity          IN NUMBER DEFAULT g_miss_num
  , p_transaction_uom   IN VARCHAR2 DEFAULT g_miss_char
  , p_inventory_item_id IN NUMBER DEFAULT g_miss_num
  , p_base_uom          IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_quantity NUMBER;
  BEGIN
    -- validate input parameters
    IF p_quantity = g_miss_num
       OR p_quantity IS NULL
       OR p_transaction_uom = g_miss_char
       OR p_transaction_uom IS NULL
       OR p_inventory_item_id = g_miss_num
       OR p_inventory_item_id IS NULL
       OR p_base_uom = g_miss_char
       OR p_base_uom IS NULL THEN
      RETURN NULL;
    END IF;

    --
    -- standard way of rounding capacity:
    -- convert capacity to base uom
    -- cut decimals
    -- ( convert back to transaction uom )
    IF p_transaction_uom <> p_base_uom THEN
      l_quantity  := inv_convert.inv_um_convert(
                       p_inventory_item_id
                     , NULL
                     , FLOOR(inv_convert.inv_um_convert(p_inventory_item_id, NULL, p_quantity, p_transaction_uom, p_base_uom, NULL, NULL))
                     , p_base_uom
                     , p_transaction_uom
                     , NULL
                     , NULL
                     );
    ELSE
      l_quantity  := FLOOR(p_quantity);
    END IF;

    --
    IF l_quantity <= 0 THEN -- can happen, if conversion isn't defined
      RETURN 0;
    END IF;

    --
    RETURN l_quantity;
  END rounddown;

  --
  -- API name    : GetTotalUnitCapacity
  -- Type        : Private
  -- Function    : Returns total unit capacity of a location regardless any unit
  --               of measure.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where unit capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  FUNCTION gettotalunitcapacity(
    p_organization_id   IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id        IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_capacity        NUMBER;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(240);
    l_loc_max_units   NUMBER;
    l_loc_cur_units   NUMBER;
    l_loc_sug_units   NUMBER;
    l_loc_avail_units NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num THEN
      l_capacity  := NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL THEN
      l_capacity  := NULL;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      l_capacity  := 1e125;
    -- otherwise return maximum units ( no uom conversions possible )
    ELSE
      inv_loc_wms_utils.get_locator_unit_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_maximum_units     => l_loc_max_units
      , x_location_current_units     => l_loc_cur_units
      , x_location_suggested_units   => l_loc_sug_units
      , x_location_available_units   => l_loc_avail_units
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );
      l_capacity  := l_loc_max_units;

      IF l_capacity IS NULL THEN
        l_capacity  := 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END gettotalunitcapacity;

  --
  -- API name    : GetOccupiedUnitCapacity
  -- Type        : Private
  -- Function    : Returns occupied unit capacity of a location regardless any
  --               unit of measure.
  --               ( Used for capacity calculation parameters )
  FUNCTION getoccupiedunitcapacity(
    p_organization_id   IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id        IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_capacity        NUMBER;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(240);
    l_loc_max_units   NUMBER;
    l_loc_cur_units   NUMBER;
    l_loc_sug_units   NUMBER;
    l_loc_avail_units NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num THEN
      l_capacity  := NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL THEN
      l_capacity  := NULL;
    -- get on-hand regardless UOM
    ELSIF p_locator_id IS NULL THEN
      l_capacity  := 0;
    ELSE
      inv_loc_wms_utils.get_locator_unit_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_maximum_units     => l_loc_max_units
      , x_location_current_units     => l_loc_cur_units
      , x_location_suggested_units   => l_loc_sug_units
      , x_location_available_units   => l_loc_avail_units
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );


      IF l_loc_cur_units IS NULL THEN
        l_loc_cur_units := 0;
      END IF;
      IF l_loc_sug_units IS NULL THEN
         l_loc_sug_units := 0;
      END IF;
      l_capacity  := l_loc_cur_units + l_loc_sug_units;
    END IF;

    --
    RETURN l_capacity;
  --
  END getoccupiedunitcapacity;

  --
  -- API name    : GetAvailableUnitCapacity
  -- Type        : Private
  -- Function    : Returns available unit capacity of a location considering
  --               on-hand stock regardless any unit of measure.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where unit capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  FUNCTION getavailableunitcapacity(
    p_organization_id   IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id        IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_capacity        NUMBER;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(240);
    l_loc_max_units   NUMBER;
    l_loc_cur_units   NUMBER;
    l_loc_sug_units   NUMBER;
    l_loc_avail_units NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num THEN
      l_capacity  := NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL THEN
      l_capacity  := NULL;
    -- get on-hand regardless UOM
    ELSIF p_locator_id IS NULL THEN
      l_capacity  := 1e125;
    ELSE
      inv_loc_wms_utils.get_locator_unit_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_maximum_units     => l_loc_max_units
      , x_location_current_units     => l_loc_cur_units
      , x_location_suggested_units   => l_loc_sug_units
      , x_location_available_units   => l_loc_avail_units
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );
      l_capacity  := l_loc_avail_units;

      IF l_capacity IS NULL THEN
        l_capacity  := 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END getavailableunitcapacity;

  --
  -- API name    : GetRemainingUnitCapacity
  -- Type        : Private
  -- Function    : Returns remaining unit capacity of a location, assuming the
  --               actual receipt would have been performed already, regardless
  --               any unit of measure.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where unit capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  FUNCTION getremainingunitcapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_transaction_quantity IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_available_capacity NUMBER;
    l_capacity           NUMBER;
  BEGIN
    -- if transaction quantity is null or missing -> something is wrong -> abort
    IF p_transaction_quantity = g_miss_num
       OR p_transaction_quantity IS NULL THEN
      RETURN NULL;
    END IF;

    -- get available capacity
    l_available_capacity  := getavailableunitcapacity(p_organization_id, p_subinventory_code, p_locator_id);

    --
    -- if available capacity is null -> something is wrong -> abort
    IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity  := l_available_capacity - p_transaction_quantity;
    END IF;

    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;

    --
    RETURN l_capacity;
  --
  END getremainingunitcapacity;

  --
  -- API name    : GetTotalVolumeCapacity
  -- Type        : Private
  -- Function    : Returns total volume or weight capacity of a location
  --               measured in transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their volume or weight.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where volume or weight
  --               capacity can not be calculated, the following definitions are
  --               made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no volume or weight )
  FUNCTION gettotalvolumecapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_volume          IN NUMBER DEFAULT g_miss_num
  , p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_capacity         NUMBER;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1);
    l_volume_uom_code  VARCHAR2(3);
    l_max_cubic_area   NUMBER;
    l_cur_cubic_area   NUMBER;
    l_sug_cubic_area   NUMBER;
    l_avail_cubic_area NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_volume = g_miss_num
       OR p_unit_volume_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom 	= g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
    ELSIF p_unit_volume IS NULL
          OR p_unit_volume_uom_code IS NULL THEN
      RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
    ELSIF p_unit_volume <= 0 THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 1e125;
    ELSE
      inv_loc_wms_utils.get_locator_volume_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_volume_uom_code            => l_volume_uom_code
      , x_max_cubic_area             => l_max_cubic_area
      , x_current_cubic_area         => l_cur_cubic_area
      , x_suggested_cubic_area       => l_sug_cubic_area
      , x_available_cubic_area       => l_avail_cubic_area
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );

      --  max cubic area is NULL if setup data is missing
      --  If setup data is missing or wrong, return infinite
      IF l_max_cubic_area IS NULL THEN
        RETURN 1e125;
      END IF;

      --if zero, no need to convert
      IF l_max_cubic_area <= 0 THEN
        RETURN 0;
      END IF;


      IF p_unit_volume_uom_code <> l_volume_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert(
                           p_inventory_item_id
                         , NULL
                         , l_max_cubic_area
                         , l_volume_uom_code
                         , p_unit_volume_uom_code
                         , NULL
                         , NULL
                         )
                       / p_unit_volume;
         --  l_capacity is negative if setup data is missing or wrong
         --  If setup data is missing or wrong, return infinite
         IF l_capacity < 0 THEN
           RETURN 1e125;
         END IF;
      ELSE
        l_capacity  := l_max_cubic_area / p_unit_volume;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_capacity, p_primary_uom, p_transaction_uom, NULL, NULL);
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;

      l_capacity  := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END gettotalvolumecapacity;

  --
  -- API name    : GetTotalWeightCapacity
  -- Type        : Private
  -- Function    : Returns total weight capacity of a location
  --               measured in transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their volume or weight.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where weight
  --               capacity can not be calculated, the following definitions are
  --               made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no volume or weight )
  FUNCTION gettotalweightcapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_weight          IN NUMBER DEFAULT g_miss_num
  , p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_capacity        NUMBER;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1);
    l_weight_uom_code VARCHAR2(3);
    l_max_weight      NUMBER;
    l_cur_weight      NUMBER;
    l_sug_weight      NUMBER;
    l_avail_weight    NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_weight = g_miss_num
       OR p_unit_weight_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom = g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
    ELSIF p_unit_weight IS NULL
          OR p_unit_weight_uom_code IS NULL THEN
      RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
    ELSIF p_unit_weight <= 0 THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 1e125;
    ELSE
      inv_loc_wms_utils.get_locator_weight_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_weight_uom_code   => l_weight_uom_code
      , x_max_weight                 => l_max_weight
      , x_current_weight             => l_cur_weight
      , x_suggested_weight           => l_sug_weight
      , x_available_weight           => l_avail_weight
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );

      --  max weight is NULL if setup data is missing
      --  If setup data is missing or wrong, return infinite
      IF l_max_weight IS NULL THEN
        RETURN 1e125;
      END IF;

      IF l_max_weight <=0 THEN
	RETURN 0;
      END IF;

      IF p_unit_weight_uom_code <> l_weight_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert_new(
                           p_inventory_item_id
                         , NULL
                         , l_max_weight
                         , l_weight_uom_code
                         , p_unit_weight_uom_code
                         , NULL
                         , NULL, 'W'
                         )
                       / p_unit_weight;
         --  l_capacity is negative if setup data is missing or wrong
         --  If setup data is missing or wrong, return infinite
         IF l_capacity < 0 THEN
           RETURN 1e125;
         END IF;
      ELSE
        l_capacity  := l_max_weight / p_unit_weight;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_capacity, p_primary_uom, p_transaction_uom, NULL, NULL);
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;

      l_capacity  := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END gettotalweightcapacity;

  --
  -- API name    : GetOccupiedVolumeCapacity
  -- Type        : Private
  -- Function    : Returns occupied volume capacity of a location measured in
  --               transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, virtually occupy the location
  --                        already according to their volume.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where volume capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of missing setup data at the item, occupied
  --                 capacity is zero ( meaning: item then has no volume )
  FUNCTION getoccupiedvolumecapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_volume          IN NUMBER DEFAULT g_miss_num
  , p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_capacity         NUMBER;
    l_volume           NUMBER;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1);
    l_volume_uom_code  VARCHAR2(3);
    l_max_cubic_area   NUMBER;
    l_cur_cubic_area   NUMBER;
    l_sug_cubic_area   NUMBER;
    l_avail_cubic_area NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_volume = g_miss_num
       OR p_unit_volume_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom = g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 0;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return zero
    ELSIF p_unit_volume IS NULL
          OR p_unit_volume_uom_code IS NULL THEN
      RETURN 0;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return zero
    ELSIF p_unit_volume <= 0 THEN
      RETURN 0;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 0;
    ELSE
      inv_loc_wms_utils.get_locator_volume_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_volume_uom_code            => l_volume_uom_code
      , x_max_cubic_area             => l_max_cubic_area
      , x_current_cubic_area         => l_cur_cubic_area
      , x_suggested_cubic_area       => l_sug_cubic_area
      , x_available_cubic_area       => l_avail_cubic_area
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );
      --  if cur or sug volume is NULL, set to 0
      --  If setup data is missing or wrong, return infinite
      l_capacity  := NVL(l_cur_cubic_area, 0) + NVL(l_sug_cubic_area, 0);

      IF l_capacity <= 0 THEN
        RETURN 0;
      END IF;

      IF p_unit_volume_uom_code <> l_volume_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert_new(
                           p_inventory_item_id
                         , NULL
                         , l_capacity
                         , l_volume_uom_code
                         , p_unit_volume_uom_code
                         , NULL
                         , NULL, 'V'
                         )
                       / p_unit_volume;
         IF l_capacity <= 0 THEN
           RETURN 0;
         END IF;
      ELSE
        l_capacity  := l_capacity / p_unit_volume;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  :=
		inv_convert.inv_um_convert(
			p_inventory_item_id,
			NULL,
			l_capacity,
			p_primary_uom,
			p_transaction_uom,
			NULL,
			NULL);
         IF l_capacity <= 0 THEN
           RETURN 0;
         END IF;
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return zero
      IF l_capacity <= 0 THEN
        RETURN 0;
      END IF;

      l_capacity  := rounddown(l_capacity,
			       p_transaction_uom,
			       p_inventory_item_id,
			       p_base_uom);

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 0;
      END IF;
    END IF;

    RETURN l_capacity;
  END getoccupiedvolumecapacity;

  --
  --
  -- API name    : GetOccupiedWeightCapacity
  -- Type        : Private
  -- Function    : Returns occupied weight capacity of a location measured in
  --               transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, virtually occupy the location
  --                        already according to their weight.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where weight capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of missing setup data at the item, occupied
  --                 capacity is zero ( meaning: item then has no weight )
  FUNCTION getoccupiedweightcapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_weight          IN NUMBER DEFAULT g_miss_num
  , p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_capacity        NUMBER;
    l_weight          NUMBER;
    --
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1);
    l_weight_uom_code VARCHAR2(3);
    l_max_weight      NUMBER;
    l_cur_weight      NUMBER;
    l_sug_weight      NUMBER;
    l_avail_weight    NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_weight = g_miss_num
       OR p_unit_weight_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom = g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 0;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return 0
    ELSIF p_unit_weight IS NULL
          OR p_unit_weight_uom_code IS NULL THEN
      RETURN 0;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return 0
    ELSIF p_unit_weight <= 0 THEN
      RETURN 0;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 0;
    ELSE
      inv_loc_wms_utils.get_locator_weight_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_weight_uom_code   => l_weight_uom_code
      , x_max_weight                 => l_max_weight
      , x_current_weight             => l_cur_weight
      , x_suggested_weight           => l_sug_weight
      , x_available_weight           => l_avail_weight
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );
      --  if cur and sug weight are NULL, set them to 0
      --  If setup data is missing or wrong, return infinite
      l_capacity  := NVL(l_cur_weight, 0) + NVL(l_sug_weight, 0);

      IF l_capacity <= 0 THEN
        RETURN 0;
      END IF;

      IF p_unit_weight_uom_code <> l_weight_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert_new(
                           p_inventory_item_id
                         , NULL
                         , l_capacity
                         , l_weight_uom_code
                         , p_unit_weight_uom_code
                         , NULL
                         , NULL, 'W'
                         )
                       / p_unit_weight;
         IF l_capacity <= 0 THEN
           RETURN 0;
         END IF;
      ELSE
        l_capacity  := l_capacity / p_unit_weight;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_capacity, p_primary_uom, p_transaction_uom, NULL, NULL);
        IF l_capacity <= 0 THEN
           RETURN 0;
        END IF;
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 0;
      END IF;

      l_capacity  := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

    END IF;

    RETURN l_capacity;
  END getoccupiedweightcapacity;

  --
  -- API name    : GetAvailableVolumeCapacity
  -- Type        : Private
  -- Function    : Returns available volume capacity of a location measured in
  --               transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their volume considering the capacity
  --                        already occupied by on-hand stock.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where volume capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no volume )
  FUNCTION getavailablevolumecapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_volume          IN NUMBER DEFAULT g_miss_num
  , p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_total_capacity    NUMBER;
    l_occupied_capacity NUMBER;
    l_capacity          NUMBER;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(1);
    l_volume_uom_code   VARCHAR2(3);
    l_max_cubic_area    NUMBER;
    l_cur_cubic_area    NUMBER;
    l_sug_cubic_area    NUMBER;
    l_avail_cubic_area  NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_volume = g_miss_num
       OR p_unit_volume_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom = g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
    ELSIF p_unit_volume IS NULL
          OR p_unit_volume_uom_code IS NULL THEN
      RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
    ELSIF p_unit_volume <= 0 THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 1e125;
    ELSE
      inv_loc_wms_utils.get_locator_volume_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_volume_uom_code            => l_volume_uom_code
      , x_max_cubic_area             => l_max_cubic_area
      , x_current_cubic_area         => l_cur_cubic_area
      , x_suggested_cubic_area       => l_sug_cubic_area
      , x_available_cubic_area       => l_avail_cubic_area
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );

      --  avail cubic area is NULL if setup data is missing
      --  If setup data is missing or wrong, return infinite
      IF l_avail_cubic_area IS NULL THEN
        RETURN 1e125;
      END IF;

      IF l_avail_cubic_area <= 0 THEN
        RETURN 0;
      END IF;

      IF p_unit_volume_uom_code <> l_volume_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert_new(
                           p_inventory_item_id
                         , NULL
                         , l_avail_cubic_area
                         , l_volume_uom_code
                         , p_unit_volume_uom_code
                         , NULL
                         , NULL, 'V'
                         )
                       / p_unit_volume;
         IF l_capacity < 0 THEN
           RETURN 1e125;
         END IF;
      ELSE
        l_capacity  := l_avail_cubic_area / p_unit_volume;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_capacity, p_primary_uom, p_transaction_uom, NULL, NULL);
         IF l_capacity < 0 THEN
           RETURN 1e125;
         END IF;
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;

      l_capacity  := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END getavailablevolumecapacity;

  --
  -- API name    : GetAvailableWeightCapacity
  -- Type        : Private
  -- Function    : Returns available weight capacity of a location measured in
  --               transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their weight considering the capacity
  --                        already occupied by on-hand stock.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where weight capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no weight )
  FUNCTION getavailableweightcapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_weight          IN NUMBER DEFAULT g_miss_num
  , p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  )
    RETURN NUMBER IS
    l_total_capacity    NUMBER;
    l_occupied_capacity NUMBER;
    l_capacity          NUMBER;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(1);
    l_weight_uom_code   VARCHAR2(3);
    l_max_weight        NUMBER;
    l_cur_weight        NUMBER;
    l_sug_weight        NUMBER;
    l_avail_weight      NUMBER;
  BEGIN
    -- missing input parameters, something is wrong -> null capacity
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_inventory_item_id = g_miss_num
       OR p_unit_weight = g_miss_num
       OR p_unit_weight_uom_code = g_miss_char
       OR p_primary_uom = g_miss_char
       OR p_transaction_uom = g_miss_char
       OR p_base_uom = g_miss_char THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_inventory_item_id IS NULL THEN
      RETURN NULL;
    ELSIF p_primary_uom IS NULL
          OR p_transaction_uom IS NULL
          OR p_base_uom IS NULL THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
    ELSIF p_unit_weight IS NULL
          OR p_unit_weight_uom_code IS NULL THEN
      RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
    ELSIF p_unit_weight <= 0 THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
    ELSIF p_locator_id IS NULL THEN
      RETURN 1e125;
    ELSE
      inv_loc_wms_utils.get_locator_weight_capacity(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_location_weight_uom_code   => l_weight_uom_code
      , x_max_weight                 => l_max_weight
      , x_current_weight             => l_cur_weight
      , x_suggested_weight           => l_sug_weight
      , x_available_weight           => l_avail_weight
      , p_organization_id            => p_organization_id
      , p_inventory_location_id      => p_locator_id
      );

      --  avail weight is NULL if setup data is missing
      --  If setup data is missing or wrong, return infinite
      IF l_avail_weight IS NULL THEN
        RETURN 1e125;
      END IF;

      IF l_avail_weight <= 0 THEN
        RETURN 0;
      END IF;

      IF p_unit_weight_uom_code <> l_weight_uom_code THEN
        l_capacity  :=   inv_convert.inv_um_convert_new(
                           p_inventory_item_id
                         , NULL
                         , l_avail_weight
                         , l_weight_uom_code
                         , p_unit_weight_uom_code
                         , NULL
                         , NULL, 'W'
                         )
                       / p_unit_weight;
         --  l_capacity is negative if setup data is missing or wrong
         --  If setup data is missing or wrong, return infinite
         IF l_capacity < 0 THEN
           RETURN 1e125;
         END IF;
      ELSE
        l_capacity  := l_avail_weight / p_unit_weight;
      END IF;

      IF p_primary_uom <> p_transaction_uom THEN
        l_capacity  := inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_capacity, p_primary_uom, p_transaction_uom, NULL, NULL);
        --  l_capacity is negative if setup data is missing or wrong
        --  If setup data is missing or wrong, return infinite
        IF l_capacity < 0 THEN
           RETURN 1e125;
        END IF;
      END IF;

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;

      l_capacity  := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

      --  l_capacity is negative if setup data is missing or wrong
      --  If setup data is missing or wrong, return infinite
      IF l_capacity < 0 THEN
        RETURN 1e125;
      END IF;
    END IF;

    RETURN l_capacity;
  END getavailableweightcapacity;

  --
  -- API name    : GetRemainingVolumeCapacity
  -- Type        : Private
  -- Function    : Returns remaining available volume capacity of a location
  --               measured in transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their volume considering the capacity
  --                        already occupied by on-hand stock and assuming the
  --                        actual receipt would have been performed already.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where volume capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no volume )
  FUNCTION getremainingvolumecapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_volume          IN NUMBER DEFAULT g_miss_num
  , p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_quantity IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_available_capacity NUMBER;
    l_capacity           NUMBER;
  BEGIN
    --
    -- if transaction quantity is null or missing -> something is wrong -> abort
    IF p_transaction_quantity = g_miss_num
       OR p_transaction_quantity IS NULL THEN
      RETURN NULL;
    END IF;

    --
    -- get available capacity
    l_available_capacity  := getavailablevolumecapacity(
                               p_organization_id
                             , p_subinventory_code
                             , p_locator_id
                             , p_inventory_item_id
                             , p_unit_volume
                             , p_unit_volume_uom_code
                             , p_primary_uom
                             , p_transaction_uom
                             , p_base_uom
                             );

    --
    -- if available capacity is null -> something is wrong -> abort
    IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity  := l_available_capacity - p_transaction_quantity;
    END IF;

    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;

    -- No need to round - we did it in GetAvailable...
    -- round it reasonably
    --l_capacity            := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

    --
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;

    --
    RETURN l_capacity;
  END getremainingvolumecapacity;

  --
  -- API name    : GetRemainingWeightCapacity
  -- Type        : Private
  -- Function    : Returns remaining available weight capacity of a location
  --               measured in transaction UOM of the actual item.
  --               Meaning: The function determines, how many items, measured in
  --                        transaction UOM, will fit into the location
  --                        according to their weight considering the capacity
  --                        already occupied by on-hand stock and assuming the
  --                        actual receipt would have been performed already.
  --               ( Used for capacity calculation parameters )
  -- Notes       : Since there are several situations, where weight capacity can
  --               not be calculated, the following definitions are made:
  --               - in case of subinventories w/o locators, capacity is
  --                 infinite
  --               - in case of missing setup data at the locator, capacity is
  --                 infinite
  --               - in case of missing setup data at the item, capacity is
  --                 infinite ( meaning: item then has no weight )
  FUNCTION getremainingweightcapacity(
    p_organization_id      IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id           IN NUMBER DEFAULT g_miss_num
  , p_inventory_item_id    IN NUMBER DEFAULT g_miss_num
  , p_unit_weight          IN NUMBER DEFAULT g_miss_num
  , p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
  , p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
  , p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  , p_transaction_quantity IN NUMBER DEFAULT g_miss_num
  )
    RETURN NUMBER IS
    l_available_capacity NUMBER;
    l_capacity           NUMBER;
  BEGIN
    --
    -- if transaction quantity is null or missing -> something is wrong -> abort
    IF p_transaction_quantity = g_miss_num
       OR p_transaction_quantity IS NULL THEN
      RETURN NULL;
    END IF;

    --
    -- get available capacity
    l_available_capacity  := getavailableweightcapacity(
                               p_organization_id
                             , p_subinventory_code
                             , p_locator_id
                             , p_inventory_item_id
                             , p_unit_weight
                             , p_unit_weight_uom_code
                             , p_primary_uom
                             , p_transaction_uom
                             , p_base_uom
                             );

    --
    -- if available capacity is null -> something is wrong -> abort
    IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity  := l_available_capacity - p_transaction_quantity;
    END IF;

    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;

    -- No need to round - we did it in GetAvailable...
    -- round it reasonably
    --l_capacity            := rounddown(l_capacity, p_transaction_uom, p_inventory_item_id, p_base_uom);

    --
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;

    --
    RETURN l_capacity;
  END getremainingweightcapacity;


--
-- API name    : GetMinimumTotalVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of total volume and total weight capacity
--               of a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
--
FUNCTION GetMinimumTotalVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER

   ) RETURN NUMBER
  IS

   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;

BEGIN

  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_max_weight IS NULL OR
     p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 THEN

    l_weight_capacity := 1e125;
  ELSE
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            p_max_weight,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := p_max_weight / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 1e125;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_max_cubic_area IS NULL OR
     p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 THEN

    l_volume_capacity := 1e125;
  ELSE
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            p_max_cubic_area,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := p_max_cubic_area / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 1e125;
    END IF;
  END IF;

  -- Find minimum value
  IF l_weight_capacity < l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;

  --no need to convert or round if capacity is zero or infinite
  IF l_capacity NOT IN (1e125,0) THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;
  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return infinite
  IF l_capacity < 0 THEN
        RETURN 1e125;
  END IF;

  RETURN l_capacity;

END GetMinimumTotalVWCapacity;

--
-- API name    : GetMinimumTotalVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of total volume and total weight capacity
--               of a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
--
FUNCTION GetMinimumTotalVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER
  IS

   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;


BEGIN
   --
/*
   l_capacity :=
     GetTotalVolumeCapacity ( p_organization_id
			     ,p_subinventory_code
			     ,p_locator_id
			     ,p_inventory_item_id
			     ,p_unit_volume
			     ,p_unit_volume_uom_code
			     ,p_primary_uom
			     ,p_transaction_uom
			     ,p_base_uom );
   --
   l_tempcapa :=
     GetTotalWeightCapacity ( p_organization_id
			     ,p_subinventory_code
			     ,p_locator_id
			     ,p_inventory_item_id
			     ,p_unit_weight
			     ,p_unit_weight_uom_code
			     ,p_primary_uom
			     ,p_transaction_uom
			     ,p_base_uom );
   --
*/

  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
  ELSIF p_locator_id         IS NULL THEN
      RETURN 1e125;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMinimumTotalVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

  RETURN l_capacity;


END GetMinimumTotalVWCapacity;

--
-- API name    : GetMaximumOccupiedVWCapacity
-- Type        : Private
-- Function    : Returns the maximum of occupied volume and occupied weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMaximumOccupiedVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER

   ) RETURN NUMBER
  IS

   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;
BEGIN

  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 THEN

    l_weight_capacity := 0;
  ELSE
    l_weight_capacity := NVL(p_current_weight, 0) + NVL(p_suggested_weight, 0);
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_weight_capacity,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := l_weight_capacity / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return zero
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 0;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 THEN

    l_volume_capacity := 0;
  ELSE
    l_volume_capacity := NVL(p_current_cubic_area,0) + NVL(p_suggested_cubic_area,0);
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_volume_capacity,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := l_volume_capacity / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 0;
    END IF;
  END IF;

  -- Find minimum value
  IF l_weight_capacity > l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;

  -- if capacity is zero, no need to convert or round
  IF l_capacity > 0 THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;

  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return zero
  IF l_capacity < 0 THEN
        RETURN 0;
  END IF;

  return l_capacity;

END;


--
-- API name    : GetMaximumOccupiedVWCapacity
-- Type        : Private
-- Function    : Returns the maximum of occupied volume and occupied weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMaximumOccupiedVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER
  IS

   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;

BEGIN
/*
   --
   l_capacity :=
     GetOccupiedVolumeCapacity ( p_organization_id
				,p_subinventory_code
				,p_locator_id
				,p_inventory_item_id
				,p_unit_volume
				,p_unit_volume_uom_code
				,p_primary_uom
				,p_transaction_uom
				,p_base_uom   );
   --
   l_tempcapa :=
     GetOccupiedWeightCapacity (p_organization_id
				,p_subinventory_code
				,p_locator_id
				,p_inventory_item_id
				,p_unit_weight
				,p_unit_weight_uom_code
				,p_primary_uom
				,p_transaction_uom
				,p_base_uom   );
   --
    IF l_tempcapa IS NOT NULL THEN
      IF l_capacity IS NULL THEN
        l_capacity := l_tempcapa;
      ELSIF l_capacity < l_tempcapa THEN
        l_capacity := l_tempcapa;
      END IF;
    END IF;
    --
    RETURN l_capacity;
*/

  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 0;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return zero
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 0;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return zero
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 0;
    -- if no locator specified -> sub w/o loc -> zero occupied
  ELSIF p_locator_id         IS NULL THEN
      RETURN 0;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMaximumOccupiedVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

  RETURN l_capacity;

END GetMaximumOccupiedVWCapacity;
--
-- API name    : GetMinimumAvailableVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of available volume and available weight
--               capacity of a location measured in transaction UOM of the
--               actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumAvailableVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER
IS

   l_capacity      NUMBER;
   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;

BEGIN


  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 OR
     p_available_weight IS NULL THEN

    l_weight_capacity := 1e125;
  ELSE
    l_weight_capacity := p_available_weight;
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_weight_capacity,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := l_weight_capacity / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 1e125;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 OR
     p_available_cubic_area  IS NULL THEN

    l_volume_capacity := 1e125;
  ELSE
    l_volume_capacity :=p_available_cubic_area;
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_volume_capacity,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := l_volume_capacity / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 1e125;
    END IF;
  END IF;

  -- Find minimum value
  IF l_weight_capacity < l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;

  -- no need to convert or round if capacity is zero or infinite
  IF l_capacity NOT IN (1e125,0) THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;
  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return infinite
  IF l_capacity < 0 THEN
        RETURN 1e125;
  END IF;

  return l_capacity;

END;


FUNCTION GetMinimumAvailableVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER
  IS

   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;

BEGIN
   --
/*
   l_capacity :=
     GetAvailableVolumeCapacity ( p_organization_id
				 ,p_subinventory_code
				 ,p_locator_id
				 ,p_inventory_item_id
				 ,p_unit_volume
				 ,p_unit_volume_uom_code
				 ,p_primary_uom
				 ,p_transaction_uom
				 ,p_base_uom   );
   --
   l_tempcapa :=
     GetAvailableWeightCapacity ( p_organization_id
				 ,p_subinventory_code
				 ,p_locator_id
				 ,p_inventory_item_id
				 ,p_unit_weight
				 ,p_unit_weight_uom_code
				 ,p_primary_uom
				 ,p_transaction_uom
				 ,p_base_uom   );
   --
   IF l_tempcapa IS NOT NULL THEN
      IF l_capacity IS NULL THEN
        l_capacity := l_tempcapa;
       ELSIF l_capacity > l_tempcapa THEN
        l_capacity := l_tempcapa;
      END IF;
    END IF;

    RETURN l_capacity;
*/

  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
  ELSIF p_locator_id         IS NULL THEN
      RETURN 1e125;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMinimumAvailableVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

  RETURN l_capacity;

END GetMinimumAvailableVWCapacity;
--
-- API name    : GetMinimumRemainingVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of remaining available volume and
--               remaining available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate volume
--               and weight capacity functions.
FUNCTION GetMinimumRemainingVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity  IN NUMBER   DEFAULT g_miss_num
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER
IS
     l_available_capacity   NUMBER;
     l_capacity             NUMBER;

BEGIN
   -- if transaction quantity is null or missing -> something is wrong -> abort
   IF p_transaction_quantity = g_miss_num
     OR p_transaction_quantity IS NULL
       THEN
      RETURN NULL ;
   END IF;
   --
   -- get available capacity
   l_available_capacity :=
     GetMinimumAvailableVWCapacity ( p_organization_id
                                    ,p_subinventory_code
                                    ,p_locator_id
                                    ,p_inventory_item_id
                                    ,p_unit_volume
                                    ,p_unit_volume_uom_code
                                    ,p_unit_weight
                                    ,p_unit_weight_uom_code
                                    ,p_primary_uom
                                    ,p_transaction_uom
                                    ,p_base_uom
        			    ,p_location_maximum_units
                                    ,p_location_current_units
                                    ,p_location_suggested_units
                                    ,p_location_available_units
                                    ,p_weight_uom_code
                                    ,p_max_weight
                                    ,p_current_weight
                                    ,p_suggested_weight
                                    ,p_available_weight
                                    ,p_volume_uom_code
                                    ,p_max_cubic_area
                                    ,p_current_cubic_area
                                    ,p_suggested_cubic_area
                                    ,p_available_cubic_area);
   --
   -- if available capacity is null -> something is wrong -> abort
   IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity := l_available_capacity - p_transaction_quantity;
    END IF;
    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;
    --

    RETURN l_capacity;
END;


FUNCTION GetMinimumRemainingVWCapacity
  ( p_organization_id       IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code     IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id            IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id     IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight           IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code  IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom           IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom       IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom              IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity  IN NUMBER   DEFAULT g_miss_num
  ) RETURN NUMBER
  IS
     l_available_capacity   NUMBER;
     l_capacity             NUMBER;
BEGIN
   -- if transaction quantity is null or missing -> something is wrong -> abort
   IF p_transaction_quantity = g_miss_num
     OR p_transaction_quantity IS NULL
       THEN
      RETURN NULL ;
   END IF;
   --
   -- get available capacity
   l_available_capacity :=
     GetMinimumAvailableVWCapacity ( p_organization_id
				    ,p_subinventory_code
				    ,p_locator_id
				    ,p_inventory_item_id
				    ,p_unit_volume
				    ,p_unit_volume_uom_code
				    ,p_unit_weight
				    ,p_unit_weight_uom_code
				    ,p_primary_uom
				    ,p_transaction_uom
				    ,p_base_uom   );
   --
   -- if available capacity is null -> something is wrong -> abort
   IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity := l_available_capacity - p_transaction_quantity;
    END IF;
    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;
    --
   /* No need to round - we did it in Get Available
    *-- round it reasonably
    *l_capacity := RoundDown ( l_capacity
    *			     ,p_transaction_uom
    *			     ,p_inventory_item_id
    *			     ,p_base_uom );
    *
    *--
    *IF l_capacity <= 0 THEN
    *  RETURN 0;
    *END IF;
    */

    RETURN l_capacity;
END GetMinimumRemainingVWCapacity;
--
-- API name    : GetMinimumTotalUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of total unit, total volume and total
--               weight capacity of a location measured in transaction UOM of
--               the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumTotalUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER
IS

   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;
   l_loc_max_units        NUMBER;

BEGIN


  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_max_weight IS NULL OR
     p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 THEN

    l_weight_capacity := 1e125;
  ELSE
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            p_max_weight,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := p_max_weight / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 1e125;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_max_cubic_area IS NULL OR
     p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 THEN

    l_volume_capacity := 1e125;
  ELSE
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            p_max_cubic_area,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := p_max_cubic_area / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 1e125;
    END IF;
  END IF;

  l_loc_max_units := p_location_maximum_units;
  IF l_loc_max_units IS NULL THEN
    l_loc_max_units := 1e125;
  END IF;

  -- Find minimum value
  IF l_weight_capacity < l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;
  IF l_capacity > l_loc_max_units THEN
    l_capacity := l_loc_max_units;
  END IF;

  --no need to convert or round if capacity is 0 or infinite
  IF l_capacity NOT IN (1e125,0) THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;
  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return infinite
  IF l_capacity < 0 THEN
        RETURN 1e125;
  END IF;

  RETURN l_capacity;

END GetMinimumTotalUVWCapacity;


FUNCTION GetMinimumTotalUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  ) RETURN NUMBER
  IS

   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;

BEGIN
   --
/*
   l_capacity :=
     GetMinimumTotalVWCapacity ( p_organization_id
				,p_subinventory_code
				,p_locator_id
				,p_inventory_item_id
				,p_unit_volume
				,p_unit_volume_uom_code
				,p_unit_weight
				,p_unit_weight_uom_code
				,p_primary_uom
				,p_transaction_uom
				,p_base_uom );
   --
   l_tempcapa :=
     GetTotalUnitCapacity ( p_organization_id
			   ,p_subinventory_code
			   ,p_locator_id);
   --
   IF l_tempcapa IS NOT NULL THEN
      IF l_capacity IS NULL THEN
	 l_capacity := l_tempcapa;
       ELSIF l_capacity > l_tempcapa THEN
        l_capacity := l_tempcapa;
      END IF;
    END IF;

*/
  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
  ELSIF p_locator_id         IS NULL THEN
      RETURN 1e125;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMinimumTotalUVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

   Return l_capacity;

END GetMinimumTotalUVWCapacity;


--
-- API name    : GetMaximumOccupiedUVWCapacity
-- Type        : Private
-- Function    : Returns the maximum of occupied unit, occupied volume and
--               occupied weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMaximumOccupiedUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
   ) RETURN NUMBER
IS
   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;
   l_loc_cur_units        NUMBER;
   l_loc_sug_units        NUMBER;

BEGIN

  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 THEN

    l_weight_capacity := 0;
  ELSE
    l_weight_capacity := NVL(p_current_weight, 0) + NVL(p_suggested_weight, 0);
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_weight_capacity,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := l_weight_capacity / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return zero
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 0;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 THEN

    l_volume_capacity := 0;
  ELSE
    l_volume_capacity := NVL(p_current_cubic_area,0) + NVL(p_suggested_cubic_area,0);
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new
           (p_inventory_item_id,
            NULL,
            l_volume_capacity,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := l_volume_capacity / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 0;
    END IF;
  END IF;

  l_loc_cur_units := p_location_current_units;
  l_loc_sug_units := p_location_suggested_units;
  IF l_loc_cur_units IS NULL THEN
    l_loc_cur_units := 0;
  END IF;
  IF l_loc_sug_units IS NULL THEN
    l_loc_sug_units := 0;
  END IF;


  -- Find minimum value
  IF l_weight_capacity > l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;
  IF l_capacity < l_loc_cur_units + l_loc_sug_units THEN
    l_capacity := l_loc_cur_units + l_loc_sug_units;
  END IF;

  -- no need to round if capacity is 0
  IF l_capacity > 0 THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;
  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return infinite
  IF l_capacity < 0 THEN
        RETURN 0;
  END IF;

  RETURN l_capacity;

END GetMaximumOccupiedUVWCapacity;


FUNCTION GetMaximumOccupiedUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ) RETURN NUMBER
  IS

   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;

BEGIN
   --
/*
   l_capacity :=
     GetMaximumOccupiedVWCapacity ( p_organization_id
				   ,p_subinventory_code
				   ,p_locator_id
				   ,p_inventory_item_id
				   ,p_unit_volume
				   ,p_unit_volume_uom_code
				   ,p_unit_weight
				   ,p_unit_weight_uom_code
				   ,p_primary_uom
				   ,p_transaction_uom
				   ,p_base_uom );
   --
   l_tempcapa :=
     GetOccupiedUnitCapacity ( p_organization_id
			      ,p_subinventory_code
			      ,p_locator_id    );
   --
   IF l_tempcapa IS NOT NULL THEN
      IF l_capacity IS NULL THEN
	 l_capacity := l_tempcapa;
       ELSIF l_capacity < l_tempcapa THEN
        l_capacity := l_tempcapa;
      END IF;
   END IF;
*/
  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 0;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return zero occuppied
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 0;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 0;
    -- if no locator specified -> sub w/o loc -> no occuppied capacity
  ELSIF p_locator_id         IS NULL THEN
      RETURN 0;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMaximumOccupiedUVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

   Return l_capacity;

END GetMaximumOccupiedUVWCapacity;
--
-- API name    : GetMinimumAvailableUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of available unit, available volume and
--               available weight capacity of a location measured in
--               transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumAvailableUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER
IS
   l_weight_capacity      NUMBER;
   l_volume_capacity      NUMBER;
   l_capacity		  NUMBER;
   l_loc_avail_units      NUMBER;

BEGIN

  -- if necessary parameters are present, convert max weight into
  -- txn UOM
  IF p_unit_weight          IS NULL OR
     p_unit_weight_uom_code IS NULL OR
     p_unit_weight <= 0 OR
     p_available_weight IS NULL THEN

    l_weight_capacity := 1e125;
  ELSE
    l_weight_capacity := p_available_weight;
    IF p_unit_weight_uom_code <> p_weight_uom_code THEN
        l_weight_capacity := inv_convert.inv_um_convert_new -- INV_UM_CONVERT_NEW
           (p_inventory_item_id,
            NULL,
            l_weight_capacity,
            p_weight_uom_code,
            p_unit_weight_uom_code,
            NULL,
            NULL, 'W') / p_unit_weight;
    ELSE
         l_weight_capacity := l_weight_capacity / p_unit_weight;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_weight_capacity < 0 THEN
         l_weight_capacity := 1e125;
    END IF;
  END IF;

  -- if necessary parameters are present, convert max volume into
  -- txn UOM
  IF p_unit_volume          IS NULL OR
     p_unit_volume_uom_code IS NULL OR
     p_unit_volume <= 0 OR
     p_available_cubic_area IS NULL THEN

    l_volume_capacity := 1e125;
  ELSE
    l_volume_capacity := p_available_cubic_area;
    IF p_unit_volume_uom_code <> p_volume_uom_code THEN
        l_volume_capacity := inv_convert.inv_um_convert_new -- INV_UM_CONVERT_NEW
           (p_inventory_item_id,
            NULL,
            l_volume_capacity,
            p_volume_uom_code,
            p_unit_volume_uom_code,
            NULL,
            NULL, 'V') / p_unit_volume;
    ELSE
         l_volume_capacity := l_volume_capacity / p_unit_volume;
    END IF;

    --  l_capacity is negative if setup data is missing or wrong
    --  If setup data is missing or wrong, return infinite
    IF l_volume_capacity < 0 THEN
         l_volume_capacity := 1e125;
    END IF;
  END IF;

  l_loc_avail_units := p_location_available_units;

  IF l_loc_avail_units IS NULL THEN
    l_loc_avail_units := 1e125;
  END IF;

  -- Find minimum value
  IF l_weight_capacity < l_volume_capacity THEN
    l_capacity := l_weight_capacity;
  ELSE
    l_capacity := l_volume_capacity;
  END IF;
  IF l_capacity > l_loc_avail_units THEN
    l_capacity := l_loc_avail_units;
  END IF;

  --no need to round or convert if capacity is zero or infinite
  IF l_capacity NOT IN (1e125,0) THEN
    IF p_primary_uom <> p_transaction_uom THEN
         l_capacity:= inv_convert.inv_um_convert  -- INV_UM_CONVERT_NEW
           (p_inventory_item_id,
            NULL,
            l_capacity,
            p_primary_uom,
            p_transaction_uom,
            NULL,
            NULL);
    END IF;

    -- Round Down
    l_capacity := RoundDown(l_capacity,
                          p_transaction_uom,
                          p_inventory_item_id,
                          p_base_uom);
  END IF;
  --  l_capacity is negative if setup data is missing or wrong
  --  If setup data is missing or wrong, return infinite
  IF l_capacity < 0 THEN
        RETURN 1e125;
  END IF;

  RETURN l_capacity;

END GetMinimumAvailableUVWCapacity;


FUNCTION GetMinimumAvailableUVWCapacity
  ( p_organization_id      IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id           IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id    IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight          IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom          IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom      IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom             IN VARCHAR2 DEFAULT g_miss_char
  ) RETURN NUMBER
  IS

   l_capacity		  NUMBER;

   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(1);

   l_loc_max_units NUMBER;
   l_loc_cur_units NUMBER;
   l_loc_sug_units NUMBER;
   l_loc_avail_units NUMBER;


   l_volume_uom_code VARCHAR2(3);
   l_max_cubic_area NUMBER;
   l_cur_cubic_area NUMBER;
   l_sug_cubic_area NUMBER;
   l_avail_cubic_area NUMBER;

   l_weight_uom_code VARCHAR2(3);
   l_max_weight NUMBER;
   l_cur_weight NUMBER;
   l_sug_weight NUMBER;
   l_avail_weight NUMBER;

BEGIN
   --
/*
   l_capacity :=
     GetAvailableUnitCapacity ( p_organization_id
			       ,p_subinventory_code
			       ,p_locator_id);
   --
   l_tempcapa :=
     GetMinimumAvailableVWCapacity ( p_organization_id
				    ,p_subinventory_code
				    ,p_locator_id
				    ,p_inventory_item_id
				    ,p_unit_volume
				    ,p_unit_volume_uom_code
				    ,p_unit_weight
				    ,p_unit_weight_uom_code
				    ,p_primary_uom
				    ,p_transaction_uom
				    ,p_base_uom );
   --
   IF l_tempcapa IS NOT NULL THEN
      IF l_capacity IS NULL THEN
	 l_capacity := l_tempcapa;
      ELSIF l_capacity > l_tempcapa THEN
	 l_capacity := l_tempcapa;
      END IF;
    END IF;
    --
*/
  -- missing input parameters, something is wrong -> null capacity
  IF p_organization_id       = g_miss_num
     OR p_subinventory_code   = g_miss_char
     OR p_locator_id          = g_miss_num
     OR p_inventory_item_id   = g_miss_num
     OR p_unit_volume          = g_miss_num
     OR p_unit_volume_uom_code = g_miss_char
     OR p_unit_weight          = g_miss_num
     OR p_unit_weight_uom_code = g_miss_char
     OR p_primary_uom          = g_miss_char
     OR p_transaction_uom      = g_miss_char
     OR p_base_uom             = g_miss_char
    THEN
      RETURN NULL;
    -- if no sub specified, something is wrong -> null capacity
  ELSIF p_organization_id     IS NULL
       OR p_subinventory_code   IS NULL
       OR p_inventory_item_id   IS NULL
    THEN
      RETURN NULL;
  ELSIF p_primary_uom IS NULL
      OR p_transaction_uom IS NULL
      OR p_base_uom IS NULL
        THEN
      RETURN 1e125;
    -- Mising item setup data regarding volume
    --  -> assumption: item has no volume -> used up capacity
    --  If setup data is missing, return infinite
  ELSIF (p_unit_volume          IS NULL
       OR p_unit_volume_uom_code IS NULL) AND
        (p_unit_weight		 IS NULL
       OR p_unit_weight_uom_code IS NULL)
    THEN
	RETURN 1e125;
    -- if unit volume is zero or negative -> same as above
    --  If setup data is missing or wrong, return infinite
  ELSIF p_unit_volume          <= 0 AND
	p_unit_weight	       <= 0
    THEN
      RETURN 1e125;
    -- if no locator specified -> sub w/o loc -> infinite capacity
  ELSIF p_locator_id         IS NULL THEN
      RETURN 1e125;
  END IF;

  inv_loc_wms_utils.get_locator_capacity
	(x_return_status	=> l_return_status
	,x_msg_count 		=> l_msg_count
	,x_msg_data		=> l_msg_data
	,x_location_maximum_units => l_loc_max_units
	,x_location_current_units => l_loc_cur_units
	,x_location_suggested_units => l_loc_sug_units
	,x_location_available_units => l_loc_avail_units
	,x_location_weight_uom_code => l_weight_uom_code
	,x_max_weight		=> l_max_weight
	,x_current_weight	=> l_cur_weight
	,x_suggested_weight	=> l_sug_weight
	,x_available_weight	=> l_avail_weight
	,x_volume_uom_code	=> l_volume_uom_code
	,x_max_cubic_area	=> l_max_cubic_area
	,x_current_cubic_area	=> l_cur_cubic_area
	,x_suggested_cubic_area => l_sug_cubic_area
	,x_available_cubic_area => l_avail_cubic_area
	,p_organization_id	=> p_organization_id
	,p_inventory_location_id => p_locator_id
	);

  l_capacity := GetMinimumAvailableUVWCapacity
       ( p_organization_id
        ,p_subinventory_code
        ,p_locator_id
        ,p_inventory_item_id
        ,p_unit_volume
        ,p_unit_volume_uom_code
        ,p_unit_weight
        ,p_unit_weight_uom_code
        ,p_primary_uom
        ,p_transaction_uom
        ,p_base_uom
        ,l_loc_max_units
        ,l_loc_cur_units
        ,l_loc_sug_units
        ,l_loc_avail_units
        ,l_weight_uom_code
        ,l_max_weight
        ,l_cur_weight
        ,l_sug_weight
        ,l_avail_weight
        ,l_volume_uom_code
        ,l_max_cubic_area
        ,l_cur_cubic_area
        ,l_sug_cubic_area
        ,l_avail_cubic_area);

   Return l_capacity;

END GetMinimumAvailableUVWCapacity;
--
-- API name    : GetMinimumRemainingUVWCapacity
-- Type        : Private
-- Function    : Returns the minimum of remaining available unit, remaining
--               available volume and remaining available weight capacity of
--               a location measured in transaction UOM of the actual item.
--               ( Used for capacity calculation parameters )
-- Notes       : refer to notes regarding the corresponding separate unit,
--               volume and weight capacity functions.
FUNCTION GetMinimumRemainingUVWCapacity
  ( p_organization_id         IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code       IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id              IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id       IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity    IN NUMBER   DEFAULT g_miss_num
   ,p_location_maximum_units IN NUMBER
   ,p_location_current_units IN NUMBER
   ,p_location_suggested_units IN NUMBER
   ,p_location_available_units IN NUMBER
   ,p_weight_uom_code       IN VARCHAR2
   ,p_max_weight            IN NUMBER
   ,p_current_weight        IN NUMBER
   ,p_suggested_weight      IN NUMBER
   ,p_available_weight      IN NUMBER
   ,p_volume_uom_code       IN VARCHAR2
   ,p_max_cubic_area        IN NUMBER
   ,p_current_cubic_area    IN NUMBER
   ,p_suggested_cubic_area  IN NUMBER
   ,p_available_cubic_area  IN NUMBER
  ) RETURN NUMBER
IS
     l_available_capacity     NUMBER;
     l_capacity               NUMBER;

BEGIN

   --
   -- if transaction quantity is null or missing-> something is wrong -> abort
   IF p_transaction_quantity = g_miss_num
     OR p_transaction_quantity IS NULL
       THEN
      RETURN NULL;
   END IF;
   --
   -- get available capacity
   l_available_capacity :=
     GetMinimumAvailableUVWCapacity ( p_organization_id
				     ,p_subinventory_code
				     ,p_locator_id
				     ,p_inventory_item_id
				     ,p_unit_volume
				     ,p_unit_volume_uom_code
				     ,p_unit_weight
				     ,p_unit_weight_uom_code
				     ,p_primary_uom
				     ,p_transaction_uom
				     ,p_base_uom
                                     ,p_location_maximum_units
                                     ,p_location_current_units
                                     ,p_location_suggested_units
                                     ,p_location_available_units
                                     ,p_weight_uom_code
                                     ,p_max_weight
                                     ,p_current_weight
                                     ,p_suggested_weight
                                     ,p_available_weight
                                     ,p_volume_uom_code
                                     ,p_max_cubic_area
                                     ,p_current_cubic_area
                                     ,p_suggested_cubic_area
                                     ,p_available_cubic_area);
   --
   -- if available capacity is null -> something is wrong -> abort
   IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity := l_available_capacity - p_transaction_quantity;
    END IF;
    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;
    --
    RETURN l_capacity;
END GetMinimumRemainingUVWCapacity;


FUNCTION GetMinimumRemainingUVWCapacity
  ( p_organization_id         IN NUMBER   DEFAULT g_miss_num
   ,p_subinventory_code       IN VARCHAR2 DEFAULT g_miss_char
   ,p_locator_id              IN NUMBER   DEFAULT g_miss_num
   ,p_inventory_item_id       IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_volume_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_unit_weight             IN NUMBER   DEFAULT g_miss_num
   ,p_unit_weight_uom_code    IN VARCHAR2 DEFAULT g_miss_char
   ,p_primary_uom             IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_uom         IN VARCHAR2 DEFAULT g_miss_char
   ,p_base_uom                IN VARCHAR2 DEFAULT g_miss_char
   ,p_transaction_quantity    IN NUMBER   DEFAULT g_miss_num
  ) RETURN NUMBER
  IS
     l_available_capacity     NUMBER;
     l_capacity               NUMBER;
BEGIN
   --
   -- if transaction quantity is null or missing-> something is wrong -> abort
   IF p_transaction_quantity = g_miss_num
     OR p_transaction_quantity IS NULL
       THEN
      RETURN NULL;
   END IF;
   --
   -- get available capacity
   l_available_capacity :=
     GetMinimumAvailableUVWCapacity ( p_organization_id
				     ,p_subinventory_code
				     ,p_locator_id
				     ,p_inventory_item_id
				     ,p_unit_volume
				     ,p_unit_volume_uom_code
				     ,p_unit_weight
				     ,p_unit_weight_uom_code
				     ,p_primary_uom
				     ,p_transaction_uom
				     ,p_base_uom );
   --
   -- if available capacity is null -> something is wrong -> abort
   IF l_available_capacity IS NULL THEN
      RETURN l_available_capacity;
    --
    -- if available capacity is infinite -> no need to subtract anything
    ELSIF l_available_capacity = 1e125 THEN
      RETURN l_available_capacity;
    --
    -- if total capacity is zero or less -> no need to subtract anything
    ELSIF l_available_capacity <= 0 THEN
      RETURN 0;
    ELSE
      -- otherwise remaining = available - txn quantity
      l_capacity := l_available_capacity - p_transaction_quantity;
    END IF;
    --
    -- we don't return any negative capacity
    IF l_capacity <= 0 THEN
      RETURN 0;
    END IF;
    --
   /* No need to round, as we did it in GetAvailableUVW...
    *-- round it reasonably
    *l_capacity := RoundDown ( l_capacity
    *			     ,p_transaction_uom
    *			     ,p_inventory_item_id
    *			     ,p_base_uom );
    *--
    *(IF l_capacity <= 0 THEN
    *  RETURN 0;
    *END IF;
    */
    --
    RETURN l_capacity;
END GetMinimumRemainingUVWCapacity;


  --bug 2200812
  -- Change from one cursor to 3 - one that assumes only item is passed,
  -- one that assumes that only item and sub is passed, and one that
  -- assumes that item, sub, and locator are passed
  --bug 2259821
  -- Added 2 arguments, loc_Inventory_item_id and loc_current_units. These
  -- parameters allow the procedure to operate more effeciently.  In some
  -- situations, there is no need to call the costly SQL statement to get
  -- the value.
  --
  -- Made p_transaction_uom and p_primary_uom optional - the procedure
  -- no longer errors out if these values aren't passed.  This change
  -- is necessary to support a new parameter which returns the
  -- Item OnHand in the primary UOM of the item.
 FUNCTION getitemonhand(
     p_organization_id           IN NUMBER DEFAULT g_miss_num
   , p_inventory_item_id         IN NUMBER DEFAULT g_miss_num
   , p_subinventory_code         IN VARCHAR2 DEFAULT g_miss_char
   , p_locator_id                IN NUMBER DEFAULT g_miss_num
   , p_primary_uom               IN VARCHAR2 DEFAULT g_miss_char
   , p_transaction_uom           IN VARCHAR2 DEFAULT g_miss_char
   , p_locator_inventory_item_id IN NUMBER DEFAULT NULL
   , p_location_current_units    IN NUMBER DEFAULT NULL
   )
     RETURN NUMBER IS
     l_primary_quantity     NUMBER;
     l_transaction_quantity NUMBER;

     -- Bug #3413372
     -- Added locator_id to the cursor l_item_onhand
     -- Only the cursor l_item_onhand is used and rest of the two cursors
     -- ignored


     CURSOR l_item_onhand IS
       SELECT  NVL(SUM(onhand.oh_quantity), 0)
           FROM (-- on-hand
                 SELECT moq.organization_id organization_id
                      , moq.inventory_item_id inventory_item_id
                      , moq.subinventory_code subinventory_code
                      , moq.locator_id locator_id
                      , moq.primary_transaction_quantity oh_quantity
                   FROM mtl_onhand_quantities_detail moq
                  -- to be more conservative ( or simply realistic ) we don't add
                  -- negative on-hand to the capacity
                  WHERE moq.transaction_quantity > 0
                 UNION ALL
                 -- pending issues/receipts and issues in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.subinventory_code
                      , mmtt.locator_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, -ABS(mmtt.primary_quantity)
                        , 3, -ABS(mmtt.primary_quantity)
                        , mmtt.primary_quantity
                        )
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(transaction_status, -1) <> 2 -- not suggestions
                 UNION ALL
                 -- receiving side in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.transfer_subinventory
                      , mmtt.transfer_to_location
                      , mmtt.primary_quantity
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(mmtt.transaction_status, -1) <> 2 -- not suggestions
                    AND mmtt.transaction_action_id IN (2, 3) -- transfers
                 UNION ALL
                 -- note: we don't add pick suggestions to capacity
                 --
                 -- put away suggestions (including transfers)
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, mmtt.transfer_subinventory
                        , 3, mmtt.transfer_subinventory
                        , mmtt.subinventory_code
                        )
                      , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_to_location, 3, mmtt.transfer_to_location, mmtt.locator_id)
                      , ABS(mmtt.primary_quantity)
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.posting_flag = 'Y'
                    AND mmtt.transaction_status = 2 -- suggestions
                    AND mmtt.transaction_action_id IN -- put away
                                                     (2, 3, 12, 27, 31, 33) -- only receipts and transfer
                 UNION ALL
                 -- put away suggestions still sitting in internal temp table
                 SELECT DECODE(mtt.transaction_action_id, 3, mtrl.to_organization_id, mtrl.organization_id)
                      , mtrl.inventory_item_id
                      , wtt.to_subinventory_code subinventory_code
                      , wtt.to_locator_id locator_id
                      , wtt.primary_quantity
                   FROM mtl_txn_request_lines mtrl, wms_transactions_temp wtt, mtl_transaction_types mtt
                  WHERE wtt.type_code = 1 -- put away
                    AND wtt.line_type_code = 2 -- output
                    AND mtrl.line_id = wtt.transaction_temp_id
                    AND mtrl.transaction_type_id = mtt.transaction_type_id) onhand
          WHERE onhand.organization_id = p_organization_id
            AND onhand.inventory_item_id = p_inventory_item_id
       GROUP BY  onhand.inventory_item_id;

     CURSOR l_sub_onhand IS
       SELECT   NVL(SUM(onhand.oh_quantity), 0)
           FROM (-- on-hand
                 SELECT moq.organization_id organization_id
                      , moq.inventory_item_id inventory_item_id
                      , moq.subinventory_code subinventory_code
                      , moq.locator_id locator_id
                      , moq.primary_transaction_quantity oh_quantity
                   FROM mtl_onhand_quantities_detail moq
                  -- to be more conservative ( or simply realistic ) we don't add
                  -- negative on-hand to the capacity
                  WHERE moq.transaction_quantity > 0
                 UNION ALL
                 -- pending issues/receipts and issues in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.subinventory_code
                      , mmtt.locator_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, -ABS(mmtt.primary_quantity)
                        , 3, -ABS(mmtt.primary_quantity)
                        , mmtt.primary_quantity
                        )
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(transaction_status, -1) <> 2 -- not suggestions
                 UNION ALL
                 -- receiving side in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.transfer_subinventory
                      , mmtt.transfer_to_location
                      , mmtt.primary_quantity
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(mmtt.transaction_status, -1) <> 2 -- not suggestions
                    AND mmtt.transaction_action_id IN (2, 3) -- transfers
                 UNION ALL
                 -- note: we don't add pick suggestions to capacity
                 --
                 -- put away suggestions (including transfers)
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, mmtt.transfer_subinventory
                        , 3, mmtt.transfer_subinventory
                        , mmtt.subinventory_code
                        )
                      , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_to_location, 3, mmtt.transfer_to_location, mmtt.locator_id)
                      , ABS(mmtt.primary_quantity)
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.posting_flag = 'Y'
                    AND mmtt.transaction_status = 2 -- suggestions
                    AND mmtt.transaction_action_id IN -- put away
                                                     (2, 3, 12, 27, 31, 33) -- only receipts and transfer
                 UNION ALL
                 -- put away suggestions still sitting in internal temp table
                 SELECT DECODE(mtt.transaction_action_id, 3, mtrl.to_organization_id, mtrl.organization_id)
                      , mtrl.inventory_item_id
                      , wtt.to_subinventory_code subinventory_code
                      , wtt.to_locator_id locator_id
                      , wtt.primary_quantity
                   FROM mtl_txn_request_lines mtrl, wms_transactions_temp wtt, mtl_transaction_types mtt
                  WHERE wtt.type_code = 1 -- put away
                    AND wtt.line_type_code = 2 -- output
                    AND mtrl.line_id = wtt.transaction_temp_id
                    AND mtrl.transaction_type_id = mtt.transaction_type_id) onhand
          WHERE onhand.organization_id = p_organization_id
            AND onhand.inventory_item_id = p_inventory_item_id
            AND onhand.subinventory_code = p_subinventory_code
       GROUP BY onhand.inventory_item_id;

     CURSOR l_loc_onhand IS
       SELECT     onhand.locator_id, NVL(SUM(onhand.oh_quantity), 0)
           FROM (-- on-hand
                 SELECT moq.organization_id organization_id
                      , moq.inventory_item_id inventory_item_id
                      , moq.subinventory_code subinventory_code
                      , moq.locator_id locator_id
                      , moq.primary_transaction_quantity oh_quantity
                   FROM mtl_onhand_quantities_detail moq
                  -- to be more conservative ( or simply realistic ) we don't add
                  -- negative on-hand to the capacity
                  WHERE moq.transaction_quantity > 0
                 UNION ALL
                 -- pending issues/receipts and issues in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.subinventory_code
                      , mmtt.locator_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, -ABS(mmtt.primary_quantity)
                        , 3, -ABS(mmtt.primary_quantity)
                        , mmtt.primary_quantity
                        )
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND nvl(mmtt.locator_id, 0) >  0  -- Added for bug # 4493640
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(transaction_status, -1) <> 2 -- not suggestions
                 UNION ALL
                 -- receiving side in transfers
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , mmtt.transfer_subinventory
                      , mmtt.transfer_to_location
                      , mmtt.primary_quantity
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.inventory_item_id > 0 -- Index !!!
                    AND nvl(mmtt.locator_id, 0) >  0  -- Added for bug # 4493640
                    AND mmtt.posting_flag = 'Y' -- pending txn
                    AND NVL(mmtt.transaction_status, -1) <> 2 -- not suggestions
                    AND mmtt.transaction_action_id IN (2, 3) -- transfers
                 UNION ALL
                 -- note: we don't add pick suggestions to capacity
                 --
                 -- put away suggestions (including transfers)
                 SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                      , mmtt.inventory_item_id
                      , DECODE(
                          mmtt.transaction_action_id
                        , 2, mmtt.transfer_subinventory
                        , 3, mmtt.transfer_subinventory
                        , mmtt.subinventory_code
                        )
                      , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_to_location, 3, mmtt.transfer_to_location, mmtt.locator_id)
                      , ABS(mmtt.primary_quantity)
                   FROM mtl_material_transactions_temp mmtt
                  WHERE mmtt.posting_flag = 'Y'
                    AND nvl(mmtt.locator_id, 0) >  0  -- Added for bug # 4493640
                    AND mmtt.transaction_status = 2 -- suggestions
                    AND mmtt.transaction_action_id IN -- put away
                                                     (2, 3, 12, 27, 31, 33) -- only receipts and transfer
                 UNION ALL
                 -- put away suggestions still sitting in internal temp table
                 SELECT DECODE(mtt.transaction_action_id, 3, mtrl.to_organization_id, mtrl.organization_id)
                      , mtrl.inventory_item_id
                      , wtt.to_subinventory_code subinventory_code
                      , wtt.to_locator_id locator_id
                      , wtt.primary_quantity
                   FROM mtl_txn_request_lines mtrl, wms_transactions_temp wtt, mtl_transaction_types mtt
                  WHERE wtt.type_code = 1 -- put away
                    AND wtt.line_type_code = 2 -- output
                    AND mtrl.line_id = wtt.transaction_temp_id
                    AND mtrl.transaction_type_id = mtt.transaction_type_id) onhand
          WHERE onhand.organization_id = p_organization_id
            AND onhand.inventory_item_id = p_inventory_item_id
            --AND onhand.subinventory_code = p_subinventory_code
            --AND onhand.locator_id = p_locator_id
       GROUP BY onhand.locator_id, onhand.inventory_item_id;

   BEGIN
 -- log_mesg('GetItemOnhand','Start', '()'  );
 -- log_mesg('GetItemOnhand','p_organization_id :', p_organization_id );
 -- log_mesg('GetItemOnhand','p_inventory_item_id :', p_inventory_item_id  );
 -- log_mesg('GetItemOnhand','p_locator_id :', p_locator_id   );
 -- log_mesg('GetItemOnhand','p_subinventory_code :', p_subinventory_code   );
 -- log_mesg('GetItemOnhand','p_primary_uom :', p_primary_uom   );
 -- log_mesg('GetItemOnhand','p_transaction_uom :', p_transaction_uom   );
    IF  (p_organization_id = g_miss_num OR                                        --check for missing org, item, or sub
          p_inventory_item_id = g_miss_num  OR
          p_organization_id IS NULL OR
          p_inventory_item_id IS NULL  )  THEN

           RETURN NULL;
    END IF;

 -- Bug 3413372 / 3573819 Performance fix

  /* Currently the cursor - l_loc_onhand is executed once per every pre-suggested row by the rules engine.
     The new code will execute the cursor once and bulk fetch the values ( Locator_id, on_hand_qty) into two
     internal tables - g_bulkCollect_Locator and g_bulkCollect_quantity. Since the  'Bulk fetch'  organizing
     the data sequentially, The data is transferred  into a third table  g_locator_item_quantity which is
     binary indexed.
     First time, after a rule being called, the value of the g_GetItemOnhq_IsRuleCached will be 'N' and the
     cursor 'l_item_onhand'  will be executed to  populate the  table - g_locator_item_quantity.
     For subsequent calls, qty for a given locator_id will be fetched from the internal table instead of
     calling the expensive  query. The internal tables and the global variables will be initialized after
     the rule being executed.
  */

     IF p_locator_id IS NOT NULL THEN
       --if the current item is the only item in the locator, the primary
       -- quantity is equal to the location current units.
     /*  Since the l_loc_onhand is executed only once, chages made for the bug 2259821 was commented out

       IF  p_locator_inventory_item_id IS NOT NULL
           AND p_locator_inventory_item_id = p_inventory_item_id THEN
         l_primary_quantity  := p_location_current_units;
       --if there is only one item in the locator, and that item is not
       -- equal to the current item, we know that no quantity of the current
       -- item resides in the locator.  Return 0.
       -- log_mesg('GetItemonhand', 'locator_id IS NOT NULL:', ''  );
         ELSIF p_locator_inventory_item_id IS NOT NULL THEN
            -- log_mesg('GetItemonhand', 'p_locator_inventory_item_id IS NOT NULL:', ''  );
            RETURN 0;
            --locator has multiple items
         ELSE

           OPEN l_loc_onhand;
           FETCH l_loc_onhand INTO l_primary_quantity;

           IF l_loc_onhand%NOTFOUND
              OR l_primary_quantity IS NULL
              OR l_primary_quantity <= 0 THEN
              CLOSE l_loc_onhand;
              RETURN 0;
           END IF;
           CLOSE l_loc_onhand;
     */
         -- log_mesg('GetItemonhand', 'g_GetItemOnhq_IsRuleCached :', g_GetItemOnhq_IsRuleCached  );
         IF (  NVL(g_GetItemOnhq_IsRuleCached, 'N')  = 'N'  ) then
		   -- log_mesg('GetItemonhand', 'Inside  IsRuleCached Check:', g_GetItemOnhq_IsRuleCached  );
		   g_GetItemOnhq_IsRuleCached := 'Y' ;
		   g_locator_item_quantity.DELETE;   		  -- Re-initialize the tables before re-using it
		   g_bulkCollect_Locator.DELETE;
		   g_bulkCollect_quantity.DELETE;

		   OPEN  l_loc_onhand;              		  -- Execute the SQL and create the cache
		   FETCH l_loc_onhand bulk collect into g_bulkCollect_Locator, g_bulkCollect_quantity;
		   IF l_loc_onhand%ROWCOUNT = 0 THEN
		      CLOSE l_loc_onhand;
		      RETURN 0;
		   END IF;
		   -- Copy the g_bulkCollect_Locator and g_bulkCollect_quantity tables
		   -- into g_locator_item_quantity
		   FOR i IN g_bulkCollect_Locator.FIRST..g_bulkCollect_Locator.LAST LOOP
		       g_locator_item_quantity(  g_bulkCollect_Locator(i) ) :=  g_bulkCollect_quantity(i);
		       -- log_mesg('GetItemonhand', 'g_locator_item_quantity:'|| to_char( g_bulkCollect_Locator(i))|| ': ', g_bulkCollect_quantity(i)  );
		   END LOOP;
	           CLOSE l_loc_onhand;
	           -- log_mesg('GetItemOnhand', 'l_loc_onhand Checking  :', 'End'  );
	   END IF;
           -- log_mesg('GetItemOnhand', 'nvl(g_locator_item_quantity(p_locator_id), 0) :', nvl(g_locator_item_quantity(p_locator_id), 0) );
          IF g_locator_item_quantity.count() <> 0 then
	    l_primary_quantity:= g_locator_item_quantity(p_locator_id);
	    -- log_mesg('GetItemOnhand', 'g_locator_item_quantity(p_locator_id)  :', g_locator_item_quantity(p_locator_id) );
         ELSE
	    l_primary_quantity:= 0;
	    -- log_mesg('GetItemonhand', 'l_primary_quantity:', l_primary_quantity  );
	 RETURN 0;
         END IF;
         -- log_mesg('GetItemonhand', 'Inise If - l_primary_quantity:', l_primary_quantity  );
         --END IF;
     ELSIF p_subinventory_code IS NOT NULL THEN
       OPEN l_sub_onhand;
       FETCH l_sub_onhand INTO l_primary_quantity;
       -- log_mesg('GetItemonhand', 'Inside Subinv  - l_primary_quantity:', l_primary_quantity  );
       IF l_sub_onhand%NOTFOUND
          OR l_primary_quantity IS NULL
          OR l_primary_quantity <= 0 THEN
         CLOSE l_sub_onhand;
         RETURN 0;
       END IF;

       CLOSE l_sub_onhand;
     ELSE
         OPEN l_item_onhand;
          FETCH l_item_onhand INTO l_primary_quantity;
          -- log_mesg('GetItemonhand', 'Inside not loc/sub   - l_primary_quantity:', l_primary_quantity  );
       IF l_item_onhand%NOTFOUND
          OR l_primary_quantity IS NULL
          OR l_primary_quantity <= 0 THEN
         CLOSE l_item_onhand;
         RETURN 0;
       END IF;

       CLOSE l_item_onhand;
     END IF;

     IF   p_primary_uom IS NOT NULL
 	AND p_transaction_uom IS NOT NULL
 	AND p_primary_uom <> p_transaction_uom THEN
 	      l_transaction_quantity  :=
 	        inv_convert.inv_um_convert(p_inventory_item_id, NULL, l_primary_quantity, p_primary_uom, p_transaction_uom, NULL, NULL);
     ELSE
 	 l_transaction_quantity  := l_primary_quantity;
     END IF;
     -- log_mesg('GetItemonhand', 'l_transaction_quantity:', l_transaction_quantity );
     IF l_transaction_quantity <= 0 THEN
         -- log_mesg('GetItemonhand', 'l_transaction_quantity <= 0:', l_transaction_quantity );
 	 RETURN 0;
     END IF;
     -- log_mesg('GetItemonhand', 'Return Value - l_transaction_quantity:', l_transaction_quantity );
     RETURN l_transaction_quantity;
   EXCEPTION
      WHEN OTHERS THEN
    --log_mesg('GetItemonhand', 'Exception - Others :','' );
        return 0;
   END getitemonhand;


  -- API name    : GetTotalOnHand
  -- Type        : Private
  -- Function    : Returns on hand stock of a given locator
  --     (all items) in the transaction UOM
  --               ( Used for capacity calculation parameters )
  FUNCTION gettotalonhand(
    p_organization_id           IN NUMBER DEFAULT g_miss_num
  , p_subinventory_code         IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_id                IN NUMBER DEFAULT g_miss_num
  , p_transaction_uom           IN VARCHAR2 DEFAULT g_miss_char
  , p_locator_inventory_item_id IN NUMBER DEFAULT NULL
  , p_location_current_units    IN NUMBER DEFAULT NULL
  , p_empty_flag                IN VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER IS
    l_primary_quantity     NUMBER;
    l_transaction_quantity NUMBER;
    l_primary_uom_code     VARCHAR(3);
    l_total_quantity       NUMBER;
    l_current_item_id      NUMBER;
    l_current_quantity     NUMBER;

    CURSOR c_primary_uom IS
      SELECT primary_uom_code
        FROM mtl_system_items
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_locator_inventory_item_id;

    --bug 2200812: change where clause so that we always assume p_locator_id is
    -- not null.  This way, the correct index on mtl_onhand_quantities_detail will
    -- be used.
    CURSOR l_tot_onhand IS
      SELECT   onhand.inventory_item_id
             , NVL(SUM(onhand.oh_quantity), 0)
             , msi.primary_uom_code
          FROM mtl_system_items msi
             , (-- on-hand
                SELECT moq.organization_id organization_id
                     , moq.inventory_item_id inventory_item_id
                     , moq.subinventory_code subinventory_code
                     , moq.locator_id locator_id
                     , moq.primary_transaction_quantity oh_quantity
                  FROM mtl_onhand_quantities_detail moq
                 -- to be more conservative ( or simply realistic ) we don't add
                 -- negative on-hand to the capacity
                 WHERE moq.transaction_quantity > 0
                UNION ALL
                -- pending issues/receipts and issues in transfers
                SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                     , mmtt.inventory_item_id
                     , mmtt.subinventory_code
                     , mmtt.locator_id
                     , DECODE(
                         mmtt.transaction_action_id
                       , 2, -ABS(mmtt.primary_quantity)
                       , 3, -ABS(mmtt.primary_quantity)
                       , mmtt.primary_quantity
                       )
                  FROM mtl_material_transactions_temp mmtt
                 WHERE mmtt.inventory_item_id > 0 -- Index !!!
                   AND mmtt.posting_flag = 'Y' -- pending txn
                   AND NVL(transaction_status, -1) <> 2 -- not suggestions
                UNION ALL
                -- receiving side in transfers
                SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                     , mmtt.inventory_item_id
                     , mmtt.transfer_subinventory
                     , mmtt.transfer_to_location
                     , mmtt.primary_quantity
                  FROM mtl_material_transactions_temp mmtt
                 WHERE mmtt.inventory_item_id > 0 -- Index !!!
                   AND mmtt.posting_flag = 'Y' -- pending txn
                   AND NVL(mmtt.transaction_status, -1) <> 2 -- not suggestions
                   AND mmtt.transaction_action_id IN (2, 3) -- transfers
                UNION ALL
                -- note: we don't add pick suggestions to capacity
                --
                -- put away suggestions (including transfers)
                SELECT DECODE(mmtt.transaction_action_id, 3, mmtt.transfer_organization, mmtt.organization_id)
                     , mmtt.inventory_item_id
                     , DECODE(
                         mmtt.transaction_action_id
                       , 2, mmtt.transfer_subinventory
                       , 3, mmtt.transfer_subinventory
                       , mmtt.subinventory_code
                       )
                     , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_to_location, 3, mmtt.transfer_to_location, mmtt.locator_id)
                     , ABS(mmtt.primary_quantity)
                  FROM mtl_material_transactions_temp mmtt
                 WHERE mmtt.transaction_status = 2   -- suggestions
                   -- AND mmtt.posting_flag = 'Y'  /* 3446963 */
                   AND mmtt.transaction_action_id IN -- put away
                                                    (2, 3, 12, 27, 31, 33) -- only receipts and transfer
                UNION ALL
                -- put away suggestions still sitting in internal temp table
                SELECT DECODE(mtt.transaction_action_id, 3, mtrl.to_organization_id, mtrl.organization_id)
                     , mtrl.inventory_item_id
                     , wtt.to_subinventory_code subinventory_code
                     , wtt.to_locator_id locator_id
                     , wtt.primary_quantity
                  FROM mtl_txn_request_lines mtrl, wms_transactions_temp wtt, mtl_transaction_types mtt
                 WHERE wtt.type_code = 1 -- put away
                   AND wtt.line_type_code = 2 -- output
                   AND mtrl.line_id = wtt.transaction_temp_id
                   AND mtrl.transaction_type_id = mtt.transaction_type_id) onhand
         WHERE onhand.organization_id = p_organization_id
           AND onhand.subinventory_code = p_subinventory_code
           AND onhand.locator_id = p_locator_id
           AND msi.inventory_item_id = onhand.inventory_item_id
           AND msi.organization_id = p_organization_id
      GROUP BY onhand.inventory_item_id, msi.primary_uom_code;
  BEGIN
    --check for missing org, item, or sub
    IF p_organization_id = g_miss_num
       OR p_subinventory_code = g_miss_char
       OR p_locator_id = g_miss_num
       OR p_transaction_uom = g_miss_char THEN
      RETURN NULL;
    ELSIF p_organization_id IS NULL
          OR p_subinventory_code IS NULL
          OR p_locator_id IS NULL
          OR p_transaction_uom IS NULL THEN
      RETURN NULL;
    END IF;

    l_total_quantity  := 0;

    IF NVL(p_empty_flag, 'N') = 'Y' THEN
      l_total_quantity  := 0;
    ELSIF p_locator_inventory_item_id IS NOT NULL THEN
      OPEN c_primary_uom;
      FETCH c_primary_uom INTO l_primary_uom_code;

      IF c_primary_uom%NOTFOUND
         OR l_primary_uom_code IS NULL
         OR p_location_current_units <= 0 THEN
        l_primary_quantity  := 0;
      ELSE
        l_primary_quantity  := p_location_current_units;
      END IF;

      IF  l_primary_quantity > 0
          AND l_primary_uom_code <> p_transaction_uom THEN
        l_total_quantity  := inv_convert.inv_um_convert(
                               p_locator_inventory_item_id
                             , NULL
                             , l_primary_quantity
                             , l_primary_uom_code
                             , p_transaction_uom
                             , NULL
                             , NULL
                             );
      ELSE
        l_total_quantity  := l_primary_quantity;
      END IF;
    ELSE
      OPEN l_tot_onhand;

      LOOP
        FETCH l_tot_onhand INTO l_current_item_id, l_primary_quantity, l_primary_uom_code;
        EXIT WHEN l_tot_onhand%NOTFOUND;

        IF l_primary_uom_code <> p_transaction_uom THEN
          l_current_quantity  :=
                 inv_convert.inv_um_convert(l_current_item_id, NULL, l_primary_quantity, l_primary_uom_code, p_transaction_uom, NULL, NULL);
        ELSE
          l_current_quantity  := l_primary_quantity;
        END IF;

        IF l_current_quantity <= 0 THEN
          l_current_quantity  := 0;
        END IF;

        l_total_quantity  := l_total_quantity + l_current_quantity;
      END LOOP;
    END IF;

    RETURN l_total_quantity;
  END gettotalonhand;

  -- API name    : IsItemInLocator
  -- Type        : Private
  -- Function    : Returns 'Y' if the given item resides in the given
  --               locator, 'N' otherwise
  FUNCTION isiteminlocator(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id        IN NUMBER
  )
    RETURN VARCHAR2 IS
    l_return_value VARCHAR2(1);
  BEGIN
    SELECT 'Y'
      INTO l_return_value
      FROM DUAL
     WHERE EXISTS( SELECT 'Y'
                     FROM mtl_onhand_quantities_detail
                    WHERE organization_id = p_organization_id
                      AND inventory_item_id = p_inventory_item_id
                      AND subinventory_code = p_subinventory_code
                      AND locator_id = p_locator_id);

    IF l_return_value = 'Y' THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END isiteminlocator;

  -- API name    : GetOuterLpnQuantityRevLot
  -- Type        : Private
  -- Function    : Returns quantity of the given item, revision, and lot
  --               in the outermost LPN containing the given LPN
  FUNCTION getouterlpnquantityrevlot(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT SUM(moqdx.primary_transaction_quantity)
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id IN (SELECT wlpn1.lpn_id
                              FROM wms_license_plate_numbers wlpn1
                             WHERE wlpn1.outermost_lpn_id = p_lpn_id)
       AND moqdx.inventory_item_id = p_inventory_item_id
       AND NVL(moqdx.revision, '-99') = NVL(p_revision, '-99')
       AND NVL(moqdx.lot_number, '-9999') = NVL(p_lot_number, '-9999');

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getouterlpnquantityrevlot;

  -- API name    : GetOuterLpnQuantity
  -- Type        : Private
  -- Function    : Returns quantity of the given item
  --               in the outermost LPN containing the given LPN
  FUNCTION getouterlpnquantity(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT SUM(moqdx.primary_transaction_quantity)
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id IN (SELECT wlpn1.lpn_id
                              FROM wms_license_plate_numbers wlpn1
                             WHERE wlpn1.outermost_lpn_id = p_lpn_id)
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getouterlpnquantity;

  -- API name    : GetOuterLpnNumOtherItems
  -- Type        : Private
  -- Function    : Returns number of items - 1
  --               in the outermost LPN containing the given LPN
  FUNCTION getouterlpnnumotheritems(p_lpn_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.inventory_item_id)) - 1
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id IN (SELECT wlpn1.lpn_id
                              FROM wms_license_plate_numbers wlpn1
                             WHERE wlpn1.outermost_lpn_id = p_lpn_id);

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getouterlpnnumotheritems;

  -- API name    : GetOuterLpnNumOtherRevs
  -- Type        : Private
  -- Function    : Returns number of revisions of this item - 1
  --               in the outermost LPN containing the given LPN
  FUNCTION getouterlpnnumotherrevs(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.revision)) - 1
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id IN (SELECT wlpn1.lpn_id
                              FROM wms_license_plate_numbers wlpn1
                             WHERE wlpn1.outermost_lpn_id = p_lpn_id)
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getouterlpnnumotherrevs;

  -- API name    : GetOuterLpnNumOtherLots
  -- Type        : Private
  -- Function    : Returns number of lots of this item - 1
  --               in the outermost LPN containing the given LPN
  FUNCTION getouterlpnnumotherlots(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.lot_number)) - 1
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id IN (SELECT wlpn1.lpn_id
                              FROM wms_license_plate_numbers wlpn1
                             WHERE wlpn1.outermost_lpn_id = p_lpn_id)
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getouterlpnnumotherlots;

  -- API name    : GetLpnQuantityRevLot
  -- Type        : Private
  -- Function    : Returns quantity of the given item, revision, and lot
  --               in the given LPN
  FUNCTION getlpnquantityrevlot(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT SUM(moqdx.primary_transaction_quantity)
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id = p_lpn_id
       AND moqdx.inventory_item_id = p_inventory_item_id
       AND NVL(moqdx.revision, '-99') = NVL(p_revision, '-99')
       AND NVL(moqdx.lot_number, '-9999') = NVL(p_lot_number, '-9999');

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END getlpnquantityrevlot;

  -- API name    : GetLpnQuantity
  -- Type        : Private
  -- Function    : Returns quantity of the given item
  --               in the given LPN
  FUNCTION getlpnquantity(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT SUM(moqdx.primary_transaction_quantity)
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id = p_lpn_id
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END getlpnquantity;

  -- API name    : GetLpnNumOtherItems
  -- Type        : Private
  -- Function    : Returns number of items - 1
  --               in the the given LPN
  FUNCTION getlpnnumotheritems(p_lpn_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.inventory_item_id))
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id = p_lpn_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getlpnnumotheritems;

  -- API name    : GetLpnNumOtherRevs
  -- Type        : Private
  -- Function    : Returns number of revisions of this item - 1
  --               in the given LPN
  FUNCTION getlpnnumotherrevs(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.revision))
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id = p_lpn_id
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getlpnnumotherrevs;

  -- API name    : GetLpnNumOtherLots
  -- Type        : Private
  -- Function    : Returns number of lots of this item - 1
  --               in the the given LPN
  FUNCTION getlpnnumotherlots(p_lpn_id IN NUMBER, p_inventory_item_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL
       OR p_inventory_item_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT COUNT(DISTINCT (moqdx.lot_number))
      INTO l_return_value
      FROM mtl_onhand_quantities_detail moqdx
     WHERE moqdx.lpn_id = p_lpn_id
       AND moqdx.inventory_item_id = p_inventory_item_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getlpnnumotherlots;

  -- API name    : GetLpnNumNestedLevels
  -- Type        : Private
  -- Function    : Returns number of LPNs between this LPN and the outermost
  --               LPN containing this LPN.  1 means that the given LPN
  --     is the outermost LPN.
  FUNCTION getlpnnumnestedlevels(p_lpn_id IN NUMBER)
    RETURN NUMBER IS
    l_return_value NUMBER;
  BEGIN
    IF p_lpn_id IS NULL THEN
      RETURN -1;
    END IF;

    SELECT     COUNT(wlpnx.lpn_id)
          INTO l_return_value
          FROM wms_license_plate_numbers wlpnx
    START WITH wlpnx.lpn_id = p_lpn_id
    CONNECT BY wlpnx.lpn_id = PRIOR parent_lpn_id;

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END getlpnnumnestedlevels;

  --==============================================================
  -- API name    : GetPOHeaderLineID
  -- Type        : Private
  -- Function    : Returns PO Header ID or Line ID based on Move Order Line
  --               Reference and Reference ID and header or line flag.
  --               ( Used for join condition in seed data  )

  FUNCTION getpoheaderlineid(
    p_transaction_source_type_id IN NUMBER
  , p_reference                  IN VARCHAR2 DEFAULT g_miss_char
  , p_reference_id               IN NUMBER DEFAULT g_miss_num
  , p_header_flag                IN VARCHAR2 DEFAULT 'N'
  , p_line_flag                  IN VARCHAR2 DEFAULT 'N'
  )
    RETURN NUMBER IS
    l_po_header_id NUMBER := -1;
    l_po_line_id   NUMBER := -1;
    l_return_val   NUMBER := -1;

    CURSOR l_po_distributions_curs IS
      SELECT po_header_id
           , po_line_id
        FROM po_distributions_all
       WHERE po_distribution_id = p_reference_id;

    CURSOR l_po_line_locations_curs IS
      SELECT po_header_id
           , po_line_id
        FROM po_line_locations_all
       WHERE line_location_id = p_reference_id;

    CURSOR l_rcv_transactions_curs IS
      SELECT po_header_id
           , po_line_id
        FROM rcv_transactions
       WHERE transaction_id = p_reference_id;
  BEGIN
    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('GetPOHeaderLineID(): ');
      inv_pp_debug.send_message_to_pipe('p_transaction_source_type_id: '|| p_transaction_source_type_id);
      inv_pp_debug.send_message_to_pipe('p_reference: '|| p_reference);
      inv_pp_debug.send_message_to_pipe('p_reference_id: '|| p_reference_id);
      inv_pp_debug.send_message_to_pipe('p_header_flag: '|| p_header_flag);
      inv_pp_debug.send_message_to_pipe('p_line_flag: '|| p_line_flag);
    END IF;

    -- validate input parameters
    IF p_transaction_source_type_id IS NULL
       OR p_reference_id = g_miss_num
       OR p_reference_id IS NULL THEN
      RETURN NULL;
    END IF;

   --bug 2983185 - use cached values
   IF (g_po_header_Id IS NULL)  or (nvl(g_po_reference_id,-1) <> p_reference_id)  THEN

    IF (p_reference = 'PO_DISTRIBUTION_ID') THEN
      OPEN l_po_distributions_curs;
      FETCH l_po_distributions_curs INTO l_po_header_id, l_po_line_id;
      CLOSE l_po_distributions_curs;
    ELSIF (p_reference = 'PO_LINE_LOCATION_ID') THEN
      OPEN l_po_line_locations_curs;
      FETCH l_po_line_locations_curs INTO l_po_header_id, l_po_line_id;
      CLOSE l_po_line_locations_curs;
    -- =========================================================
    -- transaction_source_type_id =1 indicates that mmtt record
    -- has reference to PO. This case, p_reference_id is
    -- rcv_transaction_id
    -- ==========================================================
    ELSIF (p_transaction_source_type_id = 1
           AND p_reference_id IS NOT NULL
          ) THEN
      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe('Open cursor rcv_transactions ');
      END IF;

      OPEN l_rcv_transactions_curs;
      FETCH l_rcv_transactions_curs INTO l_po_header_id, l_po_line_id;
      CLOSE l_rcv_transactions_curs;

      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe('l_po_header_id : '|| l_po_header_id);
        inv_pp_debug.send_message_to_pipe('l_po_line_id : '|| l_po_line_id);
      END IF;
    END IF;
    --bug 2983185 - PO information constant for move order line, so
    -- we don't need to constantly requery this information for every
    -- locator. Instead, store these values in global variables.
    g_po_header_id := l_po_header_id;
    g_po_line_id := l_po_line_id;
    g_po_reference_id := p_reference_id;
  END IF;

    IF (p_header_flag = 'Y') THEN
      l_return_val  := g_po_header_id;
    ELSIF (p_line_flag = 'Y') THEN
      l_return_val  := g_po_line_id;
    END IF;

    RETURN l_return_val;
END getpoheaderlineid;

  -- API name    : GetProxPickOrder
  -- Type        : Private
  -- Function    : Returns the minimum distance between this locator
  --               and the nearest locator containing the item,
  --               as calculated using the locator's picking order
  --               ( Used for building rules)
  FUNCTION getproxpickorder(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id        IN NUMBER
  )
    RETURN NUMBER IS
    l_pick_order NUMBER;

    CURSOR c_pick_order IS
      SELECT MIN(ABS(NVL(milx.picking_order, -9999) - NVL(mil.picking_order, 9999)))
        FROM mtl_item_locations mil, mtl_item_locations milx, mtl_onhand_quantities_detail moq
       WHERE mil.inventory_location_id = p_locator_id
         AND mil.organization_id = p_organization_id
         AND moq.organization_id = p_organization_id
         AND moq.inventory_item_id = p_inventory_item_id
         AND moq.subinventory_code = p_subinventory_code
         AND milx.organization_id = moq.organization_id
         AND milx.inventory_location_id = moq.locator_id;
  BEGIN
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_subinventory_code IS NULL
       OR p_locator_id IS NULL THEN
      RETURN 999999999;
    END IF;

    OPEN c_pick_order;
    FETCH c_pick_order INTO l_pick_order;

    IF c_pick_order%NOTFOUND
       OR l_pick_order IS NULL THEN
      l_pick_order  := 999999999;
    END IF;

    CLOSE c_pick_order;
    RETURN l_pick_order;
  END getproxpickorder;

  -- API name    : GetProxCoordinates
  -- Type        : Private
  -- Function    : Returns the minimum distance between this locator
  --               and the nearest locator containing the item,
  --               as calculated using xyz coordinates
  --               ( Used for building rules)
  FUNCTION getproxcoordinates(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id        IN NUMBER
  )
    RETURN NUMBER IS
    l_pick_order NUMBER;

    CURSOR c_pick_order IS
      SELECT MIN(
                 ((NVL(milx.x_coordinate, -9999) - NVL(mil.x_coordinate, 9999)) * (NVL(milx.x_coordinate, -9999) - NVL(
                                                                                                                     mil.x_coordinate
                                                                                                                   , 9999
                                                                                                                   )
                                                                                  )
                 )
               + ((NVL(milx.y_coordinate, -9999) - NVL(mil.y_coordinate, 9999)) * (NVL(milx.y_coordinate, -9999) - NVL(
                                                                                                                     mil.y_coordinate
                                                                                                                   , 9999
                                                                                                                   )
                                                                                  )
                 )
               + ((NVL(milx.z_coordinate, -9999) - NVL(mil.z_coordinate, 9999)) * (NVL(milx.z_coordinate, -9999) - NVL(
                                                                                                                     mil.z_coordinate
                                                                                                                   , 9999
                                                                                                                   )
                                                                                  )
                 )
             )
        FROM mtl_item_locations mil, mtl_item_locations milx, mtl_onhand_quantities_detail moq
       WHERE mil.inventory_location_id = p_locator_id
         AND mil.organization_id = p_organization_id
         AND moq.organization_id = p_organization_id
         AND moq.inventory_item_id = p_inventory_item_id
         AND moq.subinventory_code = p_subinventory_code
         AND milx.organization_id = moq.organization_id
         AND milx.inventory_location_id = moq.locator_id;
  BEGIN
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_subinventory_code IS NULL
       OR p_locator_id IS NULL THEN
      RETURN 999999999;
    END IF;

    OPEN c_pick_order;
    FETCH c_pick_order INTO l_pick_order;

    IF c_pick_order%NOTFOUND
       OR l_pick_order IS NULL THEN
      l_pick_order  := 999999999;
    END IF;

    CLOSE c_pick_order;
    RETURN l_pick_order;
  END getproxcoordinates;

  -- API name    : GetNumOtherItems
  -- Type        : Private
  -- Function    : Returns the number of items within the locator
  --               other than the item passed in as a parameter
  --               ( Used for building rules)
  FUNCTION getnumotheritems(
    p_organization_id           IN NUMBER
  , p_inventory_item_id         IN NUMBER
  , p_subinventory_code         IN VARCHAR2
  , p_locator_id                IN NUMBER
  , p_locator_inventory_item_id IN NUMBER DEFAULT NULL
  )
    RETURN NUMBER IS
    l_num_items NUMBER;

    CURSOR c_items IS
      SELECT COUNT(inventory_item_id)
        FROM (SELECT   inventory_item_id
                  FROM (--current onhand
                        SELECT inventory_item_id
                          FROM mtl_onhand_quantities_detail
                         WHERE organization_id = p_organization_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND inventory_item_id <> p_inventory_item_id
                        UNION ALL
                        --pending receipts and putaway suggestions
                        SELECT inventory_item_id
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND inventory_item_id <> p_inventory_item_id
                           AND transaction_action_id IN (12, 27, 31)
                        UNION ALL
                        --pending transfers and suggestions
                        SELECT inventory_item_id
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND transfer_subinventory = p_subinventory_code
                           AND transfer_to_location = p_locator_id
                           AND inventory_item_id <> p_inventory_item_id
                           AND transaction_action_id IN (2, 3, 28))
              GROUP BY inventory_item_id);
  BEGIN
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_subinventory_code IS NULL
       OR p_locator_id IS NULL THEN
      RETURN 0;
    END IF;

    --if current item is the only item in the locator, return 0
    IF  p_locator_inventory_item_id IS NOT NULL
        AND p_locator_inventory_item_id = p_inventory_item_id THEN
      l_num_items  := 0;
    --if only one item in the locator, then return 1
    ELSIF p_locator_inventory_item_id IS NOT NULL THEN
      l_num_items  := 1;
    ELSE
      OPEN c_items;
      FETCH c_items INTO l_num_items;

      IF c_items%NOTFOUND
         OR l_num_items IS NULL THEN
        l_num_items  := 0;
      END IF;

      CLOSE c_items;
    END IF;

    RETURN l_num_items;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END getnumotheritems;

  -- API name    : GetNumOtherLots
  -- Type        : Private
  -- Function    : Returns the number of lots for the given item
  --               within the locator other than the given lot
  --               ( Used for building rules)
  FUNCTION getnumotherlots(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id        IN NUMBER
  , p_lot_number        IN VARCHAR2
  )
    RETURN NUMBER IS
    l_num_lots NUMBER;

    CURSOR c_lots IS
      SELECT COUNT(lot_number)
        FROM (SELECT   lot_number
                  FROM (--current onhand
                        SELECT lot_number
                          FROM mtl_onhand_quantities_detail
                         WHERE organization_id = p_organization_id
                           AND inventory_item_id = p_inventory_item_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND lot_number IS NOT NULL
                           AND lot_number <> p_lot_number
                        UNION ALL
                        --pending receipts and putaway suggestions (lot in MMTT)
                        SELECT lot_number
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND inventory_item_id = p_inventory_item_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND lot_number IS NOT NULL
                           AND lot_number <> p_lot_number
                           AND transaction_action_id IN (12, 27, 31)
                        UNION ALL
                        --pending transfers and suggestions (lot in MMTT)
                        SELECT lot_number
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND inventory_item_id = p_inventory_item_id
                           AND transfer_subinventory = p_subinventory_code
                           AND transfer_to_location = p_locator_id
                           AND lot_number IS NOT NULL
                           AND lot_number <> p_lot_number
                           AND transaction_action_id IN (2, 3, 28)
                        UNION ALL
                        --pending receipts and putaway suggestions (lot in MTLT)
                        SELECT mtlt.lot_number
                          FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
                         WHERE mmtt.organization_id = p_organization_id
                           AND mmtt.inventory_item_id = p_inventory_item_id
                           AND mmtt.subinventory_code = p_subinventory_code
                           AND mmtt.locator_id = p_locator_id
                           AND mmtt.lot_number IS NULL
                           AND mmtt.transaction_action_id IN (12, 27, 31)
                           AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
                           AND mtlt.lot_number <> p_lot_number
                        UNION ALL
                        --pending transfers and suggestions (lot in MTLT)
                        SELECT mtlt.lot_number
                          FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
                         WHERE mmtt.organization_id = p_organization_id
                           AND mmtt.inventory_item_id = p_inventory_item_id
                           AND mmtt.transfer_subinventory = p_subinventory_code
                           AND mmtt.transfer_to_location = p_locator_id
                           AND mmtt.lot_number IS NULL
                           AND mmtt.transaction_action_id IN (2, 3, 28)
                           AND mtlt.transaction_temp_id = mmtt.transaction_temp_id
                           AND mtlt.lot_number <> p_lot_number
                        UNION ALL
                        --putaway suggestions already created for this move order
                        SELECT lot_number
                          FROM wms_transactions_temp
                         WHERE type_code = 1
                           AND line_type_code = 2
                           AND to_subinventory_code = p_subinventory_code
                           AND to_locator_id = p_locator_id
                           AND lot_number IS NOT NULL
                           AND lot_number <> p_lot_number)
              GROUP BY lot_number);
  BEGIN
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_subinventory_code IS NULL
       OR p_locator_id IS NULL
       OR p_lot_number IS NULL THEN
      RETURN 0;
    END IF;

    OPEN c_lots;
    FETCH c_lots INTO l_num_lots;

    IF c_lots%NOTFOUND
       OR l_num_lots IS NULL THEN
      l_num_lots  := 0;
    END IF;

    CLOSE c_lots;
    RETURN l_num_lots;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END getnumotherlots;

  -- API name    : GetNumOtherRevisions
  -- Type        : Private
  -- Function    : Returns the number of revisions for the given item
  --               within the locator other than the given revision
  --               ( Used for building rules)
  FUNCTION getnumotherrevisions(
    p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_locator_id        IN NUMBER
  , p_revision          IN VARCHAR2
  )
    RETURN NUMBER IS
    l_num_revisions NUMBER;

    CURSOR c_revisions IS
      SELECT COUNT(revision)
        FROM (SELECT   revision
                  FROM (--current onhand
                        SELECT revision
                          FROM mtl_onhand_quantities_detail
                         WHERE organization_id = p_organization_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND inventory_item_id = p_inventory_item_id
                           AND revision IS NOT NULL
                           AND revision <> p_revision
                        UNION ALL
                        --pending receipts and putaway suggestions
                        SELECT revision
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND subinventory_code = p_subinventory_code
                           AND locator_id = p_locator_id
                           AND inventory_item_id = p_inventory_item_id
                           AND revision IS NOT NULL
                           AND revision <> p_revision
                           AND transaction_action_id IN (12, 27, 31)
                        UNION ALL
                        --pending transfer txns and suggestions
                        SELECT revision
                          FROM mtl_material_transactions_temp
                         WHERE organization_id = p_organization_id
                           AND transfer_subinventory = p_subinventory_code
                           AND transfer_to_location = p_locator_id
                           AND inventory_item_id = p_inventory_item_id
                           AND revision IS NOT NULL
                           AND revision <> p_revision
                           AND transaction_action_id IN (2, 3, 28)
                        UNION ALL
                        --suggestions already created for this move order line
                        SELECT revision
                          FROM wms_transactions_temp
                         WHERE type_code = 1
                           AND line_type_code = 2
                           AND to_subinventory_code = p_subinventory_code
                           AND to_locator_id = p_locator_id
                           AND revision IS NOT NULL
                           AND revision <> p_revision)
              GROUP BY revision);
  BEGIN
    IF p_organization_id IS NULL
       OR p_inventory_item_id IS NULL
       OR p_subinventory_code IS NULL
       OR p_locator_id IS NULL
       OR p_revision IS NULL THEN
      RETURN 0;
    END IF;

    OPEN c_revisions;
    FETCH c_revisions INTO l_num_revisions;

    IF c_revisions%NOTFOUND
       OR l_num_revisions IS NULL THEN
      l_num_revisions  := 0;
    END IF;

    CLOSE c_revisions;
    RETURN l_num_revisions;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END getnumotherrevisions;

  FUNCTION getnumemptylocators(p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2)
    RETURN NUMBER IS
    CURSOR c_locations IS
      SELECT COUNT(inventory_location_id)
        FROM mtl_item_locations
       WHERE organization_id = p_organization_id
         AND subinventory_code = p_subinventory_code
         AND empty_flag = 'Y';

    l_hash_size  NUMBER;
    l_hash_base  NUMBER;
    l_hash_index NUMBER;
    l_empty_locs NUMBER;
  BEGIN
    IF p_organization_id IS NULL
       OR p_subinventory_code IS NULL THEN
      RETURN 0;
    END IF;

    l_hash_base   := 1;
    l_hash_size   := POWER(2, 15);
    l_hash_index  := DBMS_UTILITY.get_hash_value(NAME => p_subinventory_code, base => l_hash_base, hash_size => l_hash_size);

    LOOP
      EXIT WHEN NOT g_num_empty_locators.EXISTS(l_hash_index);
      EXIT WHEN p_subinventory_code = g_num_empty_locators(l_hash_index).subinventory_code;
      l_hash_index  := l_hash_index + 1;
    END LOOP;

    IF g_num_empty_locators.EXISTS(l_hash_index) THEN
      RETURN g_num_empty_locators(l_hash_index).num_empty_locators;
    ELSE
      OPEN c_locations;
      FETCH c_locations INTO l_empty_locs;

      IF c_locations%NOTFOUND
         OR l_empty_locs IS NULL THEN
        l_empty_locs  := 0;
      END IF;

      CLOSE c_locations;
      g_num_empty_locators(l_hash_index).subinventory_code   := p_subinventory_code;
      g_num_empty_locators(l_hash_index).num_empty_locators  := l_empty_locs;
    END IF;

    RETURN l_empty_locs;
  END getnumemptylocators;

  --==============================================================
  -- API name    : GetSOHeaderLineID
  -- Type        : Private
  -- Function    : Returns Sale Order Header ID or Line ID based
  --               on Move Order Line reference and Reference ID
  --               and header or line flag.
  --               ( Used for join condition in seed data  )

  FUNCTION getsoheaderlineid(
    p_line_id                    IN NUMBER
  , p_transaction_source_type_id IN NUMBER DEFAULT g_miss_num
  , p_reference                  IN VARCHAR2 DEFAULT g_miss_char
  , p_reference_id               IN NUMBER DEFAULT g_miss_num
  , p_header_flag                IN VARCHAR2 DEFAULT 'N'
  , p_line_flag                  IN VARCHAR2 DEFAULT 'N'
  )
    RETURN NUMBER IS
    l_header_id  NUMBER := -1;
    l_line_id    NUMBER := -1;
    l_return_val NUMBER := -1;

    CURSOR l_oe_lines_curs IS
      SELECT header_id
           , line_id
        FROM oe_order_lines_all
       WHERE line_id = p_reference_id;

    CURSOR l_wsh_delivery_details_curs IS
      SELECT source_header_id
           , source_line_id
        FROM wsh_delivery_details
       WHERE move_order_line_id = p_line_id;
    --Begin bug 4505225
    CURSOR l_oe_rcv_curs IS
      SELECT oe_order_header_id
       , oe_order_line_id
       FROM rcv_transactions
       WHERE transaction_id = p_reference_id
       AND routing_header_id = 3 ;
    --End bug 4505225
  BEGIN
    --inv_pp_debug.set_debug_mode(inv_pp_debug.g_debug_mode_yes);
    --inv_pp_debug.set_debug_pipe_name('htnguyen');

    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('GetSOHeaderLineID(): ');
      inv_pp_debug.send_message_to_pipe('p_line_id: '|| p_line_id);
      inv_pp_debug.send_message_to_pipe('p_transaction_source_type_id: '|| p_transaction_source_type_id);
      inv_pp_debug.send_message_to_pipe('p_reference: '|| p_reference);
      inv_pp_debug.send_message_to_pipe('p_reference_id: '|| p_reference_id);
      inv_pp_debug.send_message_to_pipe('p_header_flag: '|| p_header_flag);
      inv_pp_debug.send_message_to_pipe('p_line_flag: '|| p_line_flag);
    END IF;

    -- RMA = 12
    -- BUG 3205362 - For performance reasons cache the in parameters and results of this function
    IF (p_transaction_source_type_id = 12) and
      (p_reference = 'ORDER_LINE_ID') THEN
      If (p_reference_id <> nvl(g_gsohl_reference_id, -1)) OR
          (g_gsohl_header_id IS NULL) OR
          (g_gsohl_line_id IS NULL) THEN
         OPEN l_oe_lines_curs;
         FETCH l_oe_lines_curs INTO g_gsohl_header_id,g_gsohl_line_id;
         CLOSE l_oe_lines_curs;
         g_gsohl_reference_id := p_reference_id;
         g_gsohl_mo_line_id := NULL;
      END IF;
     --Begin bug 4505225
    ELSIF (p_transaction_source_type_id = 12) and (p_reference IS NULL) THEN
          If (p_reference_id <> nvl(g_gsohl_reference_id, -1)) OR
              (g_gsohl_header_id IS NULL) OR
              (g_gsohl_line_id IS NULL) THEN
             OPEN l_oe_rcv_curs;
             FETCH l_oe_rcv_curs INTO g_gsohl_header_id,g_gsohl_line_id;
             CLOSE l_oe_rcv_curs;
             g_gsohl_reference_id := p_reference_id;
             g_gsohl_mo_line_id := NULL;
          END IF;
    --End bug 4505225
    --Begin bug 5671641
    ELSIF (p_transaction_source_type_id = 2)
      And (p_reference = 'ORDER_LINE_ID_RSV') THEN
         OPEN l_oe_lines_curs;
         FETCH l_oe_lines_curs INTO g_gsohl_header_id,g_gsohl_line_id;
         CLOSE l_oe_lines_curs;
    --End bug 5671641
    ELSE
      If (p_line_id <> nvl(g_gsohl_mo_line_id, -1)) OR
          (g_gsohl_header_id IS NULL) OR
          (g_gsohl_line_id IS NULL) THEN
      -- Retrieve Sale information from shipping delivery detail
         OPEN l_wsh_delivery_details_curs;
         FETCH l_wsh_delivery_details_curs INTO g_gsohl_header_id,g_gsohl_line_id;
         CLOSE l_wsh_delivery_details_curs;
         g_gsohl_reference_id := NULL;
         g_gsohl_mo_line_id := p_line_id;
      END IF;
    END IF;
    l_line_id := g_gsohl_line_id;
    l_header_id := g_gsohl_header_id;

    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('l_header_id : '|| l_header_id);
      inv_pp_debug.send_message_to_pipe('l_line_id : '|| l_line_id);
    END IF;

    IF (p_header_flag = 'Y') THEN
      l_return_val  := l_header_id;
    ELSIF (p_line_flag = 'Y') THEN
      l_return_val  := l_line_id;
    END IF;

    RETURN l_return_val;
  END getsoheaderlineid;

  FUNCTION cart_lpn_contains_entire_del
    (p_lpn_id IN NUMBER,
     p_delivery_id IN NUMBER,
     p_business_flow_code IN NUMBER)
    RETURN VARCHAR2 IS
       l_ret         VARCHAR2(1) := 'Y';
       multiple_lpns VARCHAR2(1) := 'X';
       l_delivery_id NUMBER      := -1;
  BEGIN
     -- Bug 2631051 fix - this functions is intended to work only
     -- for the business flow of cartonization
     IF Nvl(p_business_flow_code,-1) <> 22 THEN
	l_ret := 'N';
      ELSE
	-- Bug 2631051 fix - if the delivery information is passed
	-- use that otherwise query for the delivery
	IF p_delivery_id IS NOT NULL THEN
	   l_delivery_id := p_delivery_id;
	 ELSE

           BEGIN
	      SELECT   wda.delivery_id
		INTO l_delivery_id
		FROM
		wsh_delivery_assignments_v wda,
		wsh_delivery_details wdd,
		mtl_material_transactions_temp mmtt
		WHERE
		mmtt.cartonization_id = p_lpn_id
		AND mmtt.move_order_line_id = wdd.move_order_line_id -- kkoothan Removed the NVL as part of Bug Fix:2631051
		AND wdd.delivery_detail_id = wda.delivery_detail_id
		GROUP BY wda.delivery_id;
	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		 l_ret  := 'N';
	      WHEN TOO_MANY_ROWS THEN
		 l_ret  := 'N';
	   END;


	   IF ((l_delivery_id IS NULL)
	       OR (l_delivery_id = -1)
	       ) THEN
	      l_ret  := 'N';
	   END IF;
	END IF;--else of IF p_delivery_id IS NOT NULL

	IF (l_ret = 'Y') THEN
           BEGIN
	      SELECT 'Y'
		INTO multiple_lpns
		FROM DUAL
		WHERE EXISTS( SELECT mmtt.transaction_temp_id
			      FROM mtl_material_transactions_temp mmtt, wsh_delivery_details wdd, wsh_delivery_assignments_v wda
			      WHERE NVL(mmtt.cartonization_id, -1) <> p_lpn_id
			      AND mmtt.move_order_line_id = wdd.move_order_line_id
			      AND wdd.delivery_detail_id = wda.delivery_detail_id
			      AND wda.delivery_id = l_delivery_id);
	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		 multiple_lpns  := 'N';
	      WHEN OTHERS THEN
		 multiple_lpns  := 'Y';
	   END;

	   IF multiple_lpns = 'Y' THEN
	      l_ret  := 'N';
	   END IF;
	   -- multiple lpns N => contains entire delivery

	END IF;
     END IF;--else of IF Nvl(p_business_flow_code,-1) <> 22 THEN

     RETURN l_ret;
  END cart_lpn_contains_entire_del;

  FUNCTION getearliestreceiptdate(
    p_org_id  IN NUMBER
  , p_item_id IN NUMBER
  , p_sub     IN VARCHAR2
  , p_loc_id  IN NUMBER DEFAULT NULL
  , p_lot     IN VARCHAR2 DEFAULT NULL
  , p_rev     IN VARCHAR2 DEFAULT NULL
  )
    RETURN DATE IS
    l_ret_date DATE := SYSDATE;

    -- This cursor assumes that date_recieved is never null
    CURSOR rec_dates IS
      SELECT MIN(DECODE(orig_date_received, NULL, date_received, LEAST(date_received, orig_date_received)))
        FROM mtl_onhand_quantities_detail
       WHERE organization_id = p_org_id
         AND inventory_item_id = p_item_id
         AND subinventory_code = p_sub
         AND NVL(locator_id, -1) = NVL(p_loc_id, NVL(locator_id, -1))
         AND NVL(revision, '-1') = NVL(p_rev, NVL(revision, '-1'))
         AND NVL(lot_number, '-1') = NVL(p_lot, NVL(lot_number, '-1'));
  BEGIN
    OPEN rec_dates;
    FETCH rec_dates INTO l_ret_date;

    IF (rec_dates%NOTFOUND
        OR l_ret_date IS NULL
       ) THEN
      l_ret_date  := SYSDATE;
    END IF;

    CLOSE rec_dates;
    RETURN l_ret_date;
  END getearliestreceiptdate;

  FUNCTION is_wip_transaction(p_transaction_temp_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_ret      VARCHAR2(1);
    l_hdr_type NUMBER;
  BEGIN
    l_ret  := 'N';

    BEGIN
      SELECT mtrh.move_order_type
        INTO l_hdr_type
        FROM mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id
         AND mtrl.line_id = mmtt.move_order_line_id
         AND mtrh.header_id = mtrl.header_id;

      -- Bug 2666620: BackFlush MO Type Removed
      IF (l_hdr_type = inv_globals.g_move_order_mfg_pick) THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_ret  := 'N';
    END;

    SELECT 'Y'
      INTO l_ret
      FROM DUAL
     WHERE EXISTS( SELECT transaction_temp_id
                     FROM mtl_material_transactions_temp
                    WHERE transaction_temp_id = p_transaction_temp_id
                      AND transaction_type_id IN (inv_globals.g_type_xfer_order_wip_issue, inv_globals.g_type_xfer_order_repl_subxfr));

    RETURN l_ret;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  FUNCTION is_wip_move_order(p_header_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_hdr_type NUMBER;
  BEGIN
    SELECT move_order_type
      INTO l_hdr_type
      FROM mtl_txn_request_headers mtrh
     WHERE mtrh.header_id = p_header_id;

    -- Bug 2666620: BackFlush MO Type Removed
    IF (l_hdr_type = inv_globals.g_move_order_mfg_pick) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END is_wip_move_order;

 --
  --
  FUNCTION GET_PROJECT_ATTRIBUTE(
           P_ATTRIBUTE_TYPE            IN VARCHAR2 DEFAULT g_miss_char,
           P_INVENTORY_ORGANIZATION_ID IN NUMBER DEFAULT g_miss_num,
           P_PROJECT_ID                IN NUMBER DEFAULT g_miss_num)
     RETURN VARCHAR2 IS
     l_project_name VARCHAR2(30);
     l_project_number VARCHAR2(30);
     l_planning_group VARCHAR2(30);
     l_rule_id NUMBER;


  BEGIN
     -- log_mesg('get_project_attribute','Start', '()');
     -- log_mesg('get_project_attribute','p_attribute_type :', p_attribute_type);
     -- log_mesg('get_project_attribute','p_inventory_organization_id :',p_inventory_organization_id );
     -- log_mesg('get_project_attribute','p_project_id :', p_project_id);

     -- log_mesg('get_project_attribute','g_inventory_organization_id :',g_inventory_organization_id );
     -- log_mesg('get_project_attribute','g_project_id :', g_project_id);

     IF  (p_attribute_type   = g_miss_char
	 or p_inventory_organization_id = g_miss_num
	 or p_project_id   = g_miss_num
	 or p_project_id is null
	 or p_inventory_organization_id is null)  THEN

      RETURN NULL;
     END IF;

  /*
    The query is executed once and the values of project_name, number and Group  are stored in
    the local variable which are used for subsequent pre-suggested rows to be processed by the
    rules engine. These cached values are initialized  for every rule.

   */
     -- log_mesg('Get_project_attribute',' Before  checking IsRuleCached :', g_GetProjAttr_IsRuleCached);


     IF  ((  NVL(g_GetProjAttr_IsRuleCached, 'N')   = 'N') or
           (  g_inventory_organization_id <> p_inventory_organization_id) or
           (  g_project_id  <> p_project_id )) then

        g_GetProjAttr_IsRuleCached  := 'Y';
        g_inventory_organization_id  := p_inventory_organization_id;
        g_project_id                 := p_project_id;


        ---   bug fix to improve performance
        IF P_ATTRIBUTE_TYPE = 'GROUP' THEN
           SELECT distinct planning_group
           INTO l_planning_group
           FROM pjm_project_parameters ppov
           WHERE project_id    = nvl(p_project_id, 0)
           AND organization_id = p_inventory_organization_id;

        ELSE

          SELECT ppov.project_name, ppov.project_number, ppov.planning_group
            INTO l_project_name, l_project_number, l_planning_group
            FROM PJM_PROJECTS_ORG_V ppov
           WHERE ppov.project_id = nvl(p_project_id, 0)
             AND ppov.inventory_organization_id = p_inventory_organization_id;
        END IF;

        g_project_name    := l_project_name;
        g_project_number  := l_project_number;
        g_planning_group  := l_planning_group;

        -- log_mesg('get_project_attribute','Inside the If ', ' ---'  );
        -- log_mesg('get_project_attribute','l_project_name :',   l_project_name);
        -- log_mesg('get_project_attribute','l_project_number :', l_project_number);
        -- log_mesg('get_project_attribute','l_planning_group :', l_planning_group);

     END IF;

         -- log_mesg('get_project_attribute','g_project_name :',   g_project_name);
         -- log_mesg('get_project_attribute','g_project_number :', g_project_number);
         -- log_mesg('get_project_attribute','g_planning_group :', g_planning_group);

     IF P_ATTRIBUTE_TYPE = 'NAME' 	THEN
          RETURN g_project_name;
     ELSIF P_ATTRIBUTE_TYPE = 'NUMBER' 	THEN
         RETURN g_project_number;
     ELSIF P_ATTRIBUTE_TYPE = 'GROUP' 	THEN
         RETURN g_planning_group;
     END IF;


 EXCEPTION
    WHEN OTHERS THEN
      RETURN  NULL;
 END GET_PROJECT_ATTRIBUTE;

END wms_parameter_pvt;

/
