--------------------------------------------------------
--  DDL for Package Body HR_PO_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PO_INFO" AS
/* $Header: hrpoinfo.pkb 120.0 2005/05/31 02:14:15 appldev noship $ */
/*
+==========================================================================+
|                       Copyright (c) 2003 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+

Please see the package specification for details on this package and
its procedures / functions.

Change History
-------+--------+-----------+-------+--------------------------------------|
        dcasemor 10-SEP-2003 115.0   Created for bug 3120074.
        dcasemor 15-SEP-2003 115.1   Added wrapper functions to return
                                     varchar2s instead of booleans. Changed
                                     initialise_globals to check for all
                                     4 PO columns plus tuned the SQL. Added
                                     the full_cwk_enabled pair of
                                     functions. Added procedures to return
                                     PL/SQL tables for PO bulk APIs.
        dcasemor 16-OCT-2003 115.2   Added more interoperable select
                                     procedures:
                                       - get_vendor_for_primary_asg
                                       - get_vendor_for_asg
                                       - get_po_for_primary_asg
                                       - get_po_for_asg
        dcasemor 17-OCT-2003 115.3   For the above 4 procedures, only
                                     return rows when one of the values
                                     is set to avoid the SQL returning
                                     two rows for multiple assignments.
        sramasam 22-OCT-2003 115.4   Added procedure to return url
                                     to launch Self Service CWK Placement
        dcasemor 29-JAN-2004 115.5   Added date-effective checking
                                     in get_person_for_po_line and
                                     get_person_for_vendor_site to
                                     prevent a too_many_rows exception.
        njaladi  17-mar-2004 115.6   Bug 3512537: gscc fix for sql.47
        njaladi  17-mar-2004 115.7   Bug 3512537: gscc fix for sql.47
        sbuche   26-mar-2004 115.8   Bug 3391399:
                                     Added function asg_vendor_id_exist
                                     to check the existance of vendor_id
                                     column in HR assignments tables.
        sbuche   02-APR-2002 115.9   Changes requested by OTA:
                                     Added parameter p_effective_date to
                                     the procedure get_person_for_po_line
                                     and defaulted the value Trunc(sysdate)
                                     when parameter is null.

                                     Commented following functions and
                                     procedure as they will not work
                                     when more than one person or
                                     assignment exists for a vendor site:
                                       - get_asg_id_for_vendor_site
                                       - get_person_id_for_vendor_site
                                       - get_person_for_vendor_site

                                       Modified the following procedure to
                                       remove the reference of commented
                                       procedure:
                                         - asg_exist_for_vendor_site
        svittal  21-APR-2004 115.10  Added code to generate url for PO
                                     Notification.
        svittal  13-JUN-2004 115.11  Bug fix 3666156.

        njaladi  25-May-2005 115.12  Bug Fix 4323611: Modified procedure
	                             asg_exist_for_po to use bind variables
				     instead of concatenation.
---------------------------------------------------------------------------|
*/

    --
    -- Private package constant declarations.
    --
    g_PACKAGE  CONSTANT VARCHAR2(11) := 'hr_po_info.';

    --
    -- Private package variable declarations.
    --
    g_asg_po_cols_exist BOOLEAN      := FALSE;

    -- Addded package variable to fix the Bug 3391399
    g_asg_vendor_id_exist BOOLEAN    := FALSE;
--
---------------------------------------------------------------------------|
------------------------< DEBUG_ENABLED >----------------------------------|
---------------------------------------------------------------------------|
--
FUNCTION debug_enabled RETURN BOOLEAN IS

BEGIN

    RETURN g_debug;

END debug_enabled;
--
---------------------------------------------------------------------------|
----------------------< INITIALISE_GLOBALS >-------------------------------|
---------------------------------------------------------------------------|
--
-- This procedure is private.  It is executed when the package is first
-- called; the package private flags remain cached thereafter.
--
PROCEDURE initialise_globals
IS

    e_plsql_compilation_error EXCEPTION;
    PRAGMA     EXCEPTION_INIT(e_plsql_compilation_error,-06550);
    l_count                   NUMBER;
    l_sql                     VARCHAR2(500);
-- 3512537 start
    l_status    varchar2(50);
    l_industry  varchar2(50);
    l_per_owner     varchar2(30);
    l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);
-- 3512537 end
BEGIN

    --
    -- Check if the PO columns are on the HR assignments tables.
    --
    SELECT count(dd.column_name)
    INTO   l_count
    FROM   all_tab_columns dd
    WHERE  dd.table_name  = 'PER_ALL_ASSIGNMENTS_F'
    AND   (dd.column_name = 'VENDOR_ID' OR
           dd.column_name = 'VENDOR_SITE_ID' OR
           dd.column_name = 'PO_HEADER_ID' OR
           dd.column_name = 'PO_LINE_ID')
    AND    rownum < 5
    AND    dd.owner = l_per_owner; -- 3512537

    g_asg_po_cols_exist := (l_count = 4);

    -- Added code to fix the Bug 3391399
    -- Check if VENDOR_ID column exist in the HR assignments table
    --
    SELECT count(dd.column_name)
    INTO   l_count
    FROM   all_tab_columns dd
    WHERE  dd.table_name  = 'PER_ALL_ASSIGNMENTS_F'
    AND    dd.column_name = 'VENDOR_ID'
    AND    rownum < 2
    AND    dd.owner = l_per_owner; -- 3512537

    g_asg_vendor_id_exist := (l_count = 1);
    -- End of code added for Bug 3391339

    --
    -- Determine whether HR debugging is enabled.
    -- This code uses NDS because the external function
    -- is not available in base 11i.
    --
    l_sql :=
        ' BEGIN '
      ||'     IF NOT hr_utility.debug_enabled THEN '
      ||'         hr_po_info.g_debug := FALSE; '
      ||'     END IF; '
      ||' END; ';

    EXECUTE IMMEDIATE l_sql;

EXCEPTION

    WHEN e_plsql_compilation_error THEN
        --
        -- The debug_enabled function does not exist.
        --
        NULL;

END initialise_globals;
--
---------------------------------------------------------------------------|
------------------------< FULL_CWK_ENABLED >-------------------------------|
---------------------------------------------------------------------------|
--
FUNCTION full_cwk_enabled RETURN BOOLEAN
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE || 'full_cwk_enabled';

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    --
    -- Return a boolean indicating whether services procurement is
    -- installed.
    --
    RETURN (NVL(fnd_profile.value('PO_SERVICES_ENABLED'), 'N') = 'Y');

END full_cwk_enabled;
--
---------------------------------------------------------------------------|
------------------------< FULL_CWK_ENABLED_CHAR >--------------------------|
---------------------------------------------------------------------------|
--
FUNCTION full_cwk_enabled_char RETURN VARCHAR2
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE || 'full_cwk_enabled_char';
    l_return        VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    --
    -- Return a varchar indicating whether services procurement is
    -- installed.
    --
    IF full_cwk_enabled THEN
        l_return := g_TRUE;
    END IF;

    RETURN l_return;

END full_cwk_enabled_char;
--
---------------------------------------------------------------------------|
------------------------< ASG_PO_COLS_EXIST >------------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_po_cols_exist RETURN BOOLEAN
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE || 'asg_po_cols_exist';

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    --
    -- Package instantiation ensures this flag is always set
    -- correctly.
    --
    RETURN g_asg_po_cols_exist;

END asg_po_cols_exist;
--
-- Added Function to fix the Bug 3391399
---------------------------------------------------------------------------|
------------------------< ASG_VENDOR_ID_EXIST >----------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_vendor_id_exist RETURN BOOLEAN
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE || 'asg_vendor_id_exist';

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    --
    -- Package instantiation ensures this flag is always set
    -- correctly.
    --
    RETURN g_asg_vendor_id_exist;

END asg_vendor_id_exist;
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_FOR_PO_LINE >-------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE get_person_for_po_line
    (p_po_line_id       IN         NUMBER
    ,p_person_id        OUT NOCOPY NUMBER
    ,p_assignment_id    OUT NOCOPY NUMBER
    ,p_effective_date   IN         DATE   DEFAULT NULL)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE || 'get_person_for_po_line';
    l_sql  VARCHAR2(500);
    l_effective_date DATE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
        hr_utility.set_location(to_char(p_po_line_id), 20);
    END IF;

    IF p_po_line_id IS NOT NULL AND asg_po_cols_exist THEN
        --
        -- Select the person details, given a line. NDS is used
        -- so that the procedure compiles when the columns do
        -- not exist (it is only executed when the columns do
        -- exist).
        --
        l_effective_date := nvl(p_effective_date,TRUNC(sysdate));
        l_sql :=
            ' SELECT paaf.person_id '
          ||'       ,paaf.assignment_id '
          ||' FROM   per_all_assignments_f paaf '
          ||' WHERE  paaf.po_line_id IS NOT NULL '
          ||' AND    paaf.po_line_id = '||p_po_line_id
          ||' AND    fnd_date.canonical_to_date('''
          ||         fnd_date.date_to_canonical(l_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date ';

        EXECUTE IMMEDIATE l_sql INTO p_person_id, p_assignment_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_person_for_po_line;
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_ID_FOR_PO_LINE >----------------------|
---------------------------------------------------------------------------|
--
FUNCTION get_person_id_for_po_line
    (p_po_line_id       IN         NUMBER) RETURN NUMBER
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_person_id_for_po_line';
    l_person_id NUMBER;
    l_dummy     NUMBER;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    get_person_for_po_line
        (p_po_line_id    => p_po_line_id
        ,p_person_id     => l_person_id
        ,p_assignment_id => l_dummy);

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_person_id;

END get_person_id_for_po_line;
--
---------------------------------------------------------------------------|
------------------------< GET_ASG_ID_FOR_PO_LINE >-------------------------|
---------------------------------------------------------------------------|
--
FUNCTION get_asg_id_for_po_line
    (p_po_line_id       IN         NUMBER) RETURN NUMBER
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_asg_id_for_po_line';
    l_asg_id    NUMBER;
    l_dummy     NUMBER;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    get_person_for_po_line
        (p_po_line_id    => p_po_line_id
        ,p_person_id     => l_dummy
        ,p_assignment_id => l_asg_id);

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_asg_id;

END get_asg_id_for_po_line;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO >-------------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_po
    (p_po_header_id     IN         NUMBER) RETURN BOOLEAN
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE || 'asg_exist_for_po';
    l_sql   VARCHAR2(500);
    l_found VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
        hr_utility.set_location(to_char(p_po_header_id), 20);
    END IF;

    IF p_po_header_id IS NOT NULL AND asg_po_cols_exist THEN
        --
        -- Check to see if any assignments exist for this PO.
        -- Only the first row is returned because the function
        -- simply needs to know whether an assignments exists
        -- or it does not.
        -- NDS is used to avoid column dependencies.
        --
	-- Modified Dynamic SQL to use bind variables
	--
        l_sql :=
            ' SELECT :1 '
          ||' FROM   per_all_assignments_f paaf '
          ||' WHERE  paaf.po_header_id IS NOT NULL '
          ||' AND    paaf.po_header_id = :2 '---||p_po_header_id
          ||' AND    rownum = 1';

        EXECUTE IMMEDIATE l_sql INTO l_found USING g_true,p_po_header_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

    RETURN (l_found = g_TRUE);

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

        --
        -- There are no assignments for this PO.
        --
        RETURN FALSE;

END asg_exist_for_po;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_LINE >--------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_po_line
    (p_po_line_id       IN         NUMBER) RETURN BOOLEAN
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE || 'asg_exist_for_po_line';

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    RETURN (get_asg_id_for_po_line
                (p_po_line_id => p_po_line_id) IS NOT NULL);

END asg_exist_for_po_line;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_CHAR >--------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_po_char
    (p_po_header_id     IN         NUMBER) RETURN VARCHAR2
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE
                                  ||'asg_exist_for_po_char';
    l_return         VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Record the BOOLEAN as a VARCHAR2.
    --
    IF asg_exist_for_po
           (p_po_header_id => p_po_header_id) THEN
        l_return := g_TRUE;
    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_return;

END asg_exist_for_po_char;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_LINE_CHAR >---------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_po_line_char
    (p_po_line_id       IN         NUMBER) RETURN VARCHAR2
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE
                                  ||'asg_exist_for_po_line_char';
    l_return         VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Record the BOOLEAN as a VARCHAR2.
    --
    IF asg_exist_for_po_line
           (p_po_line_id => p_po_line_id) THEN
        l_return := g_TRUE;
    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_return;

END asg_exist_for_po_line_char;
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_POS >-----------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE asgs_exist_for_pos
    (p_po_in_tbl        IN         g_table_numbers_t
    ,p_po_out_tbl       OUT NOCOPY g_table_numbers_t)
IS

    l_PROC   CONSTANT VARCHAR2(41) := g_PACKAGE || 'asgs_exist_for_pos';
    j                 NUMBER       := 1;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Enumerate through the passed in PL/SQL table.
    -- The row's index is not used but the row's value is the PO ID.
    -- For each PO ID, determine whether any assignments are
    -- assigned.
    --
    IF p_po_in_tbl.COUNT > 0 THEN

        FOR i IN p_po_in_tbl.FIRST..p_po_in_tbl.LAST LOOP

            IF g_debug THEN
                hr_utility.set_location
                    (to_char(p_po_in_tbl(i)), 20);
            END IF;

            --
            -- Only add to the out table if the PO has
            -- assignments assigned to it.
            --
            IF asg_exist_for_po
                   (p_po_header_id => p_po_in_tbl(i)) THEN
                p_po_out_tbl(j) := p_po_in_tbl(i);
                j := j + 1;
            END IF;

        END LOOP;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

END asgs_exist_for_pos;
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_PO_LINES >------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE asgs_exist_for_po_lines
    (p_po_lines_in_tbl  IN         g_table_numbers_t
    ,p_po_lines_out_tbl OUT NOCOPY g_table_numbers_t)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'asgs_exist_for_po_lines';
    j               NUMBER       := 1;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Enumerate through the passed in PL/SQL table.
    -- The row's index is not used but the row's value is the PO Line
    -- ID.  For each PO Line ID, determine whether any assignments are
    -- assigned.
    --
    IF p_po_lines_in_tbl.COUNT > 0 THEN

        FOR i IN p_po_lines_in_tbl.FIRST..p_po_lines_in_tbl.LAST LOOP

            IF g_debug THEN
                hr_utility.set_location
                    (to_char(p_po_lines_in_tbl(i)), 20);
            END IF;

            --
            -- Only add to the out table if the line has
            -- assignments assigned to it.
            --
            IF asg_exist_for_po_line
                   (p_po_line_id => p_po_lines_in_tbl(i)) THEN
                p_po_lines_out_tbl(j) := p_po_lines_in_tbl(i);
                j := j + 1;
            END IF;

        END LOOP;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

END asgs_exist_for_po_lines;
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_FOR_VENDOR_SITE >---------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Person records could exist and in
** that case this procedure will not work.
**
--
PROCEDURE get_person_for_vendor_site
    (p_vendor_site_id   IN         NUMBER
    ,p_person_id        OUT NOCOPY NUMBER
    ,p_assignment_id    OUT NOCOPY NUMBER
    ,p_effective_date   IN         DATE    DEFAULT NULL)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_person_for_vendor_site';
    l_sql  VARCHAR2(500);
    l_effective_date DATE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
        hr_utility.set_location(to_char(p_vendor_site_id), 20);
    END IF;

    IF p_vendor_site_id IS NOT NULL AND asg_po_cols_exist THEN
        --
        -- Select the person details, given a site. NDS is used
        -- so that the procedure compiles when the columns do
        -- not exist (it is only executed when the columns do
        -- exist).
        --
        l_effective_date := nvl(p_effective_date,TRUNC(sysdate));
        l_sql :=
            ' SELECT paaf.person_id '
          ||'       ,paaf.assignment_id '
          ||' FROM   per_all_assignments_f paaf '
          ||' WHERE  paaf.vendor_site_id IS NOT NULL '
          ||' AND    paaf.vendor_site_id = '||p_vendor_site_id
          ||' AND    fnd_date.canonical_to_date('''
          ||         fnd_date.date_to_canonical(l_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date ';

        EXECUTE IMMEDIATE l_sql INTO p_person_id, p_assignment_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_person_for_vendor_site;
*/
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_ID_FOR_VENDOR_SITE >------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Person could exist and in
** that case this function will not work.
**
--
FUNCTION get_person_id_for_vendor_site
    (p_vendor_site_id   IN         NUMBER) RETURN NUMBER
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_person_id_for_vendor_site';
    l_person_id NUMBER;
    l_dummy     NUMBER;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    get_person_for_vendor_site
        (p_vendor_site_id => p_vendor_site_id
        ,p_person_id      => l_person_id
        ,p_assignment_id  => l_dummy);

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_person_id;

END get_person_id_for_vendor_site;
*/
--
---------------------------------------------------------------------------|
------------------------< GET_ASG_ID_FOR_VENDOR_SITE >---------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Assignment could exist and in
** that case this function will not work.
**
--
FUNCTION get_asg_id_for_vendor_site
    (p_vendor_site_id   IN         NUMBER) RETURN NUMBER
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_asg_id_for_vendor_site';
    l_asg_id    NUMBER;
    l_dummy     NUMBER;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    get_person_for_vendor_site
        (p_vendor_site_id => p_vendor_site_id
        ,p_person_id      => l_dummy
        ,p_assignment_id  => l_asg_id);

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_asg_id;

END get_asg_id_for_vendor_site;
*/
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR >---------------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_vendor
    (p_vendor_id        IN         NUMBER) RETURN BOOLEAN
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE || 'asg_exist_for_vendor';
    l_sql   VARCHAR2(500);
    l_found VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
        hr_utility.set_location(to_char(p_vendor_id), 20);
    END IF;

    -- Bug 3391399
    -- Call function asg_vendor_id_exist instead of asg_po_cols_exist
    IF p_vendor_id IS NOT NULL AND asg_vendor_id_exist THEN
        --
        -- Check to see if any assignments exist for this vendor.
        -- Only the first row is returned because the function
        -- simply needs to know whether an assignments exists
        -- or it does not.
        -- NDS is used to avoid column dependencies.
        --
        l_sql :=
            ' SELECT '''|| g_TRUE || ''''
          ||' FROM   per_all_assignments_f paaf '
          ||' WHERE  paaf.vendor_id IS NOT NULL '
          ||' AND    paaf.vendor_id = '||p_vendor_id
          ||' AND    rownum = 1';

        EXECUTE IMMEDIATE l_sql INTO l_found;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

    RETURN (l_found = g_TRUE);

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

        --
        -- There are no assignments for this vendor.
        --
        RETURN FALSE;

END asg_exist_for_vendor;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_SITE >----------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_vendor_site
    (p_vendor_site_id   IN         NUMBER) RETURN BOOLEAN
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_asg_exist_for_vendor_site';
    l_sql           VARCHAR2(500);
    l_found         VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location(l_PROC, 10);
    END IF;

    --
    -- Check to see if any assignments exist for this site.
    -- Only the first row is returned because the function
    -- simply needs to know whether an assignments exists
    -- or it does not.
    -- NDS is used to avoid column dependencies.
    --
    l_sql :=
        ' SELECT '''|| g_TRUE || ''''
      ||' FROM   per_all_assignments_f paaf '
      ||' WHERE  paaf. vendor_site_id = '||p_vendor_site_id
      ||' AND    rownum = 1';

    EXECUTE IMMEDIATE l_sql INTO l_found;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN (l_found = g_TRUE);

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 30);
        END IF;

        --
        -- There are no assignments for this vendor site.
        --
        RETURN FALSE;
END asg_exist_for_vendor_site;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_CHAR >----------------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_vendor_char
    (p_vendor_id        IN         NUMBER) RETURN VARCHAR2
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE
                                  ||'asg_exist_for_vendor_char';
    l_return         VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Record the BOOLEAN as a VARCHAR2.
    --
    IF asg_exist_for_vendor
           (p_vendor_id => p_vendor_id) THEN
        l_return := g_TRUE;
    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_return;

END asg_exist_for_vendor_char;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_SITE_CHAR >-----------------|
---------------------------------------------------------------------------|
--
FUNCTION asg_exist_for_vendor_site_char
    (p_vendor_site_id   IN         NUMBER) RETURN VARCHAR2
IS

    l_PROC  CONSTANT VARCHAR2(41) := g_PACKAGE
                                  ||'asg_exist_for_vendor_site_char';
    l_return         VARCHAR2(5)  := g_FALSE;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Record the BOOLEAN as a VARCHAR2.
    --
    IF asg_exist_for_vendor_site
           (p_vendor_site_id => p_vendor_site_id) THEN
        l_return := g_TRUE;
    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 20);
    END IF;

    RETURN l_return;

END asg_exist_for_vendor_site_char;
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_VENDORS >-------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE asgs_exist_for_vendors
    (p_vendors_in_tbl   IN         g_table_numbers_t
    ,p_vendors_out_tbl  OUT NOCOPY g_table_numbers_t)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'asgs_exist_for_vendors';
    j               NUMBER       := 1;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Enumerate through the passed in PL/SQL table.
    -- The row's index is not used but the row's value is the vendor
    -- ID.  For each Vendor ID, determine whether any assignments are
    -- assigned.
    --
    IF p_vendors_in_tbl.COUNT > 0 THEN

        FOR i IN p_vendors_in_tbl.FIRST..p_vendors_in_tbl.LAST LOOP

            IF g_debug THEN
                hr_utility.set_location
                    (to_char(p_vendors_in_tbl(i)), 20);
            END IF;

            --
            -- Only add to the out table if the vendor has
            -- assignments.
            --
            IF asg_exist_for_vendor
                   (p_vendor_id => p_vendors_in_tbl(i)) THEN
                p_vendors_out_tbl(j) := p_vendors_in_tbl(i);
                j := j + 1;
            END IF;

        END LOOP;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

END asgs_exist_for_vendors;
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_VENDOR_SITES >--------------------|
---------------------------------------------------------------------------|
--
PROCEDURE asgs_exist_for_vendor_sites
    (p_vendor_sites_in_tbl  IN         g_table_numbers_t
    ,p_vendor_sites_out_tbl OUT NOCOPY g_table_numbers_t)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'asgs_exist_for_vendor_sites';
    j               NUMBER       := 1;

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    --
    -- Enumerate through the passed in PL/SQL table.
    -- The row's index is not used but the row's value is the vendor site
    -- ID.  For each vendor site, determine whether any assignments are
    -- assigned.
    --
    IF p_vendor_sites_in_tbl.COUNT > 0 THEN

        FOR i IN p_vendor_sites_in_tbl.FIRST..p_vendor_sites_in_tbl.LAST
        LOOP

            IF g_debug THEN
                hr_utility.set_location
                    (to_char(p_vendor_sites_in_tbl(i)), 20);
            END IF;

            --
            -- Only add to the out table if the vendor site has
            -- assignments.
            --
            IF asg_exist_for_vendor_site
                   (p_vendor_site_id => p_vendor_sites_in_tbl(i)) THEN
                p_vendor_sites_out_tbl(j) := p_vendor_sites_in_tbl(i);
                j := j + 1;
            END IF;

        END LOOP;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

END asgs_exist_for_vendor_sites;
--
---------------------------------------------------------------------------|
------------------------< GET_VENDOR_FOR_PRIMARY_ASG >---------------------|
---------------------------------------------------------------------------|
--
PROCEDURE get_vendor_for_primary_asg
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_vendor_for_primary_asg';
    l_sql           VARCHAR2(1000);

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    IF p_person_id IS NOT NULL AND p_effective_date IS NOT NULL
     AND asg_po_cols_exist THEN
        --
        -- Fetch the vendor and vendor site for the person's
        -- primary assignment.
        --
        IF g_debug THEN
            hr_utility.set_location(l_PROC, 20);
        END IF;

        l_sql :=
            ' SELECT  paaf.vendor_id '
          ||'        ,paaf.vendor_site_id '
          ||' FROM    per_all_assignments_f paaf '
          ||' WHERE   paaf.person_id = '||p_person_id
          ||' AND     paaf.primary_flag = ''Y'''
          ||' AND     fnd_date.canonical_to_date('''
          ||           fnd_date.date_to_canonical(p_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date '
          ||' AND    (paaf.vendor_id IS NOT NULL OR '
          ||'         paaf.vendor_site_id IS NOT NULL) ';

        EXECUTE IMMEDIATE l_sql INTO p_vendor_id
                                    ,p_vendor_site_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_vendor_for_primary_asg;
--
---------------------------------------------------------------------------|
------------------------< GET_VENDOR_FOR_ASG >-----------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE get_vendor_for_asg
    (p_assignment_id        IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_vendor_for_asg';
    l_sql           VARCHAR2(1000);

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    IF p_assignment_id IS NOT NULL AND p_effective_date IS NOT NULL
     AND asg_po_cols_exist THEN
        --
        -- Fetch the vendor and vendor site for the given assignment.
        --
        IF g_debug THEN
            hr_utility.set_location(l_PROC, 20);
        END IF;

        l_sql :=
            ' SELECT  paaf.vendor_id '
          ||'        ,paaf.vendor_site_id '
          ||' FROM    per_all_assignments_f paaf '
          ||' WHERE   paaf.assignment_id = '||p_assignment_id
          ||' AND     fnd_date.canonical_to_date('''
          ||           fnd_date.date_to_canonical(p_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date '
          ||' AND    (paaf.vendor_id IS NOT NULL OR '
          ||'         paaf.vendor_site_id IS NOT NULL) ';

        EXECUTE IMMEDIATE l_sql INTO p_vendor_id
                                    ,p_vendor_site_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_vendor_for_asg;
--
---------------------------------------------------------------------------|
------------------------< GET_PO_FOR_PRIMARY_ASG >-------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE get_po_for_primary_asg
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         OUT NOCOPY NUMBER
    ,p_po_line_id           OUT NOCOPY NUMBER)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_po_for_primary_asg';
    l_sql           VARCHAR2(1000);

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    IF p_person_id IS NOT NULL AND p_effective_date IS NOT NULL
     AND asg_po_cols_exist THEN
        --
        -- Fetch the PO Header and Line for the person's
        -- primary assignment.
        --
        IF g_debug THEN
            hr_utility.set_location(l_PROC, 20);
        END IF;

        l_sql :=
            ' SELECT  paaf.po_header_id '
          ||'        ,paaf.po_line_id '
          ||' FROM    per_all_assignments_f paaf '
          ||' WHERE   paaf.person_id = '||p_person_id
          ||' AND     paaf.primary_flag = ''Y'''
          ||' AND     fnd_date.canonical_to_date('''
          ||           fnd_date.date_to_canonical(p_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date '
          ||' AND    (paaf.po_header_id IS NOT NULL OR '
          ||'         paaf.po_line_id IS NOT NULL) ';

        EXECUTE IMMEDIATE l_sql INTO p_po_header_id
                                    ,p_po_line_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_po_for_primary_asg;
--
---------------------------------------------------------------------------|
------------------------< GET_PO_FOR_ASG >---------------------------------|
---------------------------------------------------------------------------|
--
PROCEDURE get_po_for_asg
    (p_assignment_id        IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         OUT NOCOPY NUMBER
    ,p_po_line_id           OUT NOCOPY NUMBER)
IS

    l_PROC CONSTANT VARCHAR2(41) := g_PACKAGE
                                 ||'get_po_for_asg';
    l_sql           VARCHAR2(1000);

BEGIN

    IF g_debug THEN
        hr_utility.set_location('Entering: ' || l_PROC, 10);
    END IF;

    IF p_assignment_id IS NOT NULL AND p_effective_date IS NOT NULL
     AND asg_po_cols_exist THEN
        --
        -- Fetch the vendor and vendor site for the given assignment.
        --
        IF g_debug THEN
            hr_utility.set_location(l_PROC, 20);
        END IF;

        l_sql :=
            ' SELECT  paaf.po_header_id '
          ||'        ,paaf.po_line_id '
          ||' FROM    per_all_assignments_f paaf '
          ||' WHERE   paaf.assignment_id = '||p_assignment_id
          ||' AND     fnd_date.canonical_to_date('''
          ||           fnd_date.date_to_canonical(p_effective_date)||''')'
          ||' BETWEEN paaf.effective_start_date '
          ||'     AND paaf.effective_end_date '
          ||' AND    (paaf.po_header_id IS NOT NULL OR '
          ||'         paaf.po_line_id IS NOT NULL) ';

        EXECUTE IMMEDIATE l_sql INTO p_po_header_id
                                    ,p_po_line_id;

    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_PROC, 30);
    END IF;

EXCEPTION

    WHEN no_data_found THEN

        IF g_debug THEN
            hr_utility.set_location('Leaving: ' || l_PROC, 40);
        END IF;

END get_po_for_asg;
--
---------------------------------------------------------------------------|
------------------------< GET_URL_PLACE_CWK >------------------------------|
---------------------------------------------------------------------------|
--
-- Given a po_line_id this procedure will return the url destination which
-- will be rendered in PO notification.
-- On launching this url the user will be taken through the CWK Placement
-- flow of pages.
--
PROCEDURE get_url_place_cwk
    (p_po_line_id           IN         NUMBER
    ,p_destination          OUT NOCOPY VARCHAR2)
IS
  cursor get_function_params (p_function_name fnd_form_functions.function_name%TYPE) is
  select web_html_call || '&' || parameters url  from fnd_form_functions
  where function_name = p_function_name;
  l_function_name fnd_form_functions.function_name%TYPE default 'HR_CWKPLACE_MGR_SS';
  l_url varchar2(1000);
  l_cutom_cwk_plc_func fnd_form_functions.function_name%TYPE;
  l_self_service_licensed varchar2(3);

BEGIN

    p_destination := null;
    --Instead of profile for customized function we have to think about some other
    --mechanism to store the customized function --Satish.
    --l_cutom_cwk_plc_func := fnd_profile.value('HR_CUST_CWK_PLACEMENT');
    --if(l_cutom_cwk_plc_func is not null)
    --then
    --   l_function_name :=  l_cutom_cwk_plc_func;
    --end if;

    open get_function_params(l_function_name);
    fetch get_function_params into l_url;
    if( l_url is not null )
    then
        p_destination := 'JSP:/OA_HTML/'  ||  l_url || '&' || 'pNtfLineId=' || p_po_line_id ;
    end if;
  --
END get_url_place_cwk;
--
--
---------------------------------------------------------------------------|
---------------------< PACKAGE INITIALISATION >----------------------------|
---------------------------------------------------------------------------|
--
BEGIN
  --
  -- Initialise package variables.
  --
  initialise_globals;

END hr_po_info;

/
