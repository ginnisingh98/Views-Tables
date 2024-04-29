--------------------------------------------------------
--  DDL for Package Body QA_SPECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SPECS_PUB" AS
/* $Header: qltpspcb.plb 120.1.12010000.2 2008/09/24 11:29:02 pdube ship $ */


--
-- Safe globals.
--

TYPE qa_specs_table IS TABLE OF qa_specs%ROWTYPE INDEX BY BINARY_INTEGER;
g_qa_specs_array   qa_specs_table;

g_pkg_name         CONSTANT VARCHAR2(30):= 'qa_specs_pub';
g_user_name_cache  fnd_user.user_name%TYPE := NULL;
g_user_id_cache    NUMBER;

--
-- General utility functions
--

FUNCTION get_user_id(p_name VARCHAR2) RETURN NUMBER IS
--
-- Decode user name from fnd_user table.
--
    id NUMBER;

    CURSOR user_cursor IS
        SELECT user_id
        FROM fnd_user
        WHERE user_name = p_name;
BEGIN

--
-- Code is duplicated in qltpspcb.plb.  Any modification here
-- should be propagated to that file.
--

    IF p_name IS NULL THEN
        RETURN nvl(fnd_global.user_id, -1);
    END IF;

    --
    -- It is very common for the same user to call the
    -- APIs successively.
    --
    IF g_user_name_cache = p_name THEN
        RETURN g_user_id_cache;
    END IF;

    OPEN user_cursor;
    FETCH user_cursor INTO id;
    IF user_cursor%NOTFOUND THEN
        CLOSE user_cursor;
        RETURN -1;
    END IF;
    CLOSE user_cursor;

    g_user_name_cache := p_name;
    g_user_id_cache := id;

    RETURN id;
END get_user_id;

--
-- Global caching mechanism.  A global array is used to kept
-- all fetched qa_specs.  If the same spec data is required in
-- a future call, the cached data will be used.
--

FUNCTION exists_qa_specs(spec_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN g_qa_specs_array.EXISTS(spec_id);

END exists_qa_specs;


PROCEDURE fetch_qa_specs(spec_id IN NUMBER) IS
--
-- Retrieve a specification header and cached.
--
    CURSOR c1 (p_id NUMBER) IS
        SELECT *
        FROM qa_specs
        WHERE spec_id = p_id;

BEGIN
    IF NOT exists_qa_specs(spec_id) THEN
        OPEN c1(spec_id);
        FETCH c1 INTO g_qa_specs_array(spec_id);
        CLOSE c1;
    END IF;
END fetch_qa_specs;


PROCEDURE fetch_qa_specs(p_spec_name IN VARCHAR2, x_spec_id OUT NOCOPY NUMBER) IS
--
-- Retrieve a specification header and cached.  Similar to
-- the previous function but query by spec name instead of id.
--
    CURSOR c1 IS
        SELECT *
        FROM qa_specs
        WHERE spec_name = p_spec_name;

    temp qa_specs%ROWTYPE;

BEGIN
    OPEN c1;
    FETCH c1 INTO temp;
    IF c1%NOTFOUND THEN
        CLOSE c1;
        RETURN;
    END IF;

    x_spec_id := temp.spec_id;
    g_qa_specs_array(x_spec_id) := temp;
    CLOSE c1;
END fetch_qa_specs;


FUNCTION item_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).item_id;

END item_id;


FUNCTION organization_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).organization_id;

END organization_id;


FUNCTION spec_name(spec_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).spec_name;

END spec_name;


FUNCTION category_set_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).category_set_id;

END category_set_id;


FUNCTION category_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).category_id;

END category_id;


FUNCTION item_revision(spec_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).item_revision;

END item_revision;


FUNCTION vendor_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).vendor_id;

END vendor_id;


FUNCTION customer_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).customer_id;

END customer_id;


FUNCTION char_id(spec_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).char_id;

END char_id;


FUNCTION spec_element_value(spec_id IN NUMBER)
    RETURN VARCHAR2  IS

BEGIN

    fetch_qa_specs(spec_id);
    IF NOT exists_qa_specs(spec_id) THEN
        RETURN NULL;
    END IF;
    RETURN g_qa_specs_array(spec_id).spec_element_value;

END spec_element_value;


FUNCTION get_context_element_id(p_element_name IN VARCHAR2)
    RETURN NUMBER IS

    CURSOR c IS
        SELECT char_id
        FROM   qa_chars
        WHERE  char_context_flag = 1 AND
               enabled_flag = 1 AND
               name = p_element_name;

    l_char_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_char_id;
    IF c%NOTFOUND THEN
        CLOSE c;
        fnd_message.set_name('QA', 'QA_API_INVALID_ELEMENT');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    CLOSE c;
    RETURN l_char_id;

END get_context_element_id;

--
-- The child specs inherit all the spec elements of the master.
--
-- rkunchal
--

PROCEDURE check_for_spec_element(p_spec_id IN NUMBER) IS

    CURSOR c IS
        SELECT 1
        FROM qa_spec_chars qsc, qa_specs qs
        WHERE qs.spec_id = p_spec_id
        AND qs.common_spec_id = qsc.spec_id;

    l_dummy     NUMBER;
    l_found     BOOLEAN;

BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    l_found := c%FOUND;
    CLOSE c;

    IF NOT l_found THEN
        fnd_message.set_name('QA', 'QA_API_SPEC_MUST_HAVE_CHARS');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

END check_for_spec_element;


FUNCTION get_revision_flag(p_item_id IN NUMBER, p_org_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR c IS
        SELECT revision_qty_control_code
        from mtl_system_items
        where inventory_item_id = p_item_id
        and organization_id = p_org_id;

    l_revision_flag NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_revision_flag;
    CLOSE c;

    RETURN l_revision_flag;

END get_revision_flag;


FUNCTION process_item_and_revision(p_item_name IN VARCHAR2, p_item_revision
    IN VARCHAR2, p_org_id IN NUMBER) RETURN NUMBER IS

    l_item_id   NUMBER;
    l_revision_flag NUMBER;

BEGIN

    l_item_id := qa_flex_util.get_item_id(p_org_id, p_item_name);

    IF (l_item_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ITEM_NAME');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    ELSE
        l_revision_flag := get_revision_flag(l_item_id, p_org_id);
        IF (l_revision_flag = 1) THEN

            IF (p_item_revision IS NOT NULL)  THEN
                fnd_message.set_name('QA', 'QA_API_REVISION_CONTROLLED');
                fnd_msg_pub.add();
                RAISE fnd_api.g_exc_error;
            END IF;

        ELSIF (l_revision_flag = 2) and (p_item_revision IS NULL)  THEN
            fnd_message.set_name('QA', 'QA_API_MANDATORY_REVISION');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;

        ELSE
            IF NOT qa_plan_element_api.validate_revision(p_org_id,
                l_item_id, p_item_revision) THEN
                fnd_message.set_name('QA', 'QA_API_INVALID_REVISION');
                fnd_msg_pub.add();
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;
    END IF;

    RETURN l_item_id;

END;


PROCEDURE validate_datatype(p_value IN VARCHAR2, p_datatype NUMBER) IS

    temp_number Number;
    temp_date Date;

BEGIN

    IF p_value IS NULL THEN
        RETURN;
    END IF;

    IF p_datatype = qa_ss_const.number_datatype THEN
        BEGIN
            temp_number := to_number(p_value);
        EXCEPTION WHEN OTHERS THEN
            fnd_message.set_name('QA', 'QA_INVALID_NUMBER');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END;

    ELSIF p_datatype = qa_ss_const.date_datatype THEN
        BEGIN
            temp_date := qltdate.any_to_date(p_value);
        EXCEPTION WHEN OTHERS THEN
            fnd_message.set_name('QA', 'QA_INVALID_DATE');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END;
    END IF;

END validate_datatype;


FUNCTION combination_exists(
    p_category_set_id           IN NUMBER,
    p_category_id               IN NUMBER,
    p_item_id                   IN NUMBER,
    p_item_revision             IN VARCHAR2,
    p_org_id                    IN NUMBER,
    p_vendor_id                 IN NUMBER,
    p_customer_id               IN NUMBER,
    p_char_id                   IN NUMBER,
    p_sub_type_element_value    IN VARCHAR2,
    x_spec_name                 OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS

    l_spec_name varchar2(30);

    CURSOR c IS
        SELECT spec_name
        FROM qa_specs
        WHERE category_set_id = p_category_set_id
            AND category_id = p_category_id
            AND item_id = p_item_id
            AND item_revision = nvl(p_item_revision, 'NONE')
            AND organization_id = p_org_id
            AND vendor_id = p_vendor_id
            AND customer_id = p_customer_id
            AND char_id = p_char_id
            AND spec_element_value = p_sub_type_element_value;

    result BOOLEAN;
    dummy  VARCHAR2(30);

BEGIN

    OPEN c;
    FETCH c INTO x_spec_name;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END combination_exists;


FUNCTION get_category_set_id(
    p_category_set_name IN VARCHAR2,
    x_structure_id OUT NOCOPY NUMBER,
    x_validate_flag OUT NOCOPY mtl_category_sets.validate_flag%TYPE)
    RETURN NUMBER IS

    CURSOR c IS
        SELECT category_set_id, structure_id, validate_flag
        FROM mtl_category_sets
        WHERE category_set_name = p_category_set_name;

    l_category_set_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_category_set_id, x_structure_id, x_validate_flag;
    CLOSE c;

    IF (l_category_set_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_CATEGORY_SET');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    RETURN l_category_set_id;

END get_category_set_id;


FUNCTION get_category_id(
    p_category_name IN VARCHAR2,
    p_category_set_id IN NUMBER,
    p_org_id IN NUMBER,
    p_structure_id IN NUMBER,
    p_validate_flag mtl_category_sets.validate_flag%TYPE)
    RETURN NUMBER IS

    -- Bug 2532177. Removed the Default value for l_category_id variable.
    l_category_id NUMBER;
    l_where_clause VARCHAR2(500);

BEGIN

    IF p_validate_flag = 'Y' THEN
        l_where_clause :=
            '(nvl(disable_date, sysdate+1) > sysdate) AND category_id IN
             (SELECT category_id
              FROM mtl_category_set_valid_cats vc
              WHERE vc.category_set_id = ' || p_category_set_id || ')';
    ELSE
        l_where_clause := '(nvl(disable_date, sysdate+1) > sysdate)';
    END IF;

    IF FND_FLEX_KEYVAL.validate_segs(
        operation => 'CHECK_COMBINATION',
        key_flex_code => 'MCAT',
        appl_short_name => 'INV',
        structure_number => p_structure_id,
        concat_segments => p_category_name,
        data_set => p_structure_id,
        where_clause => l_where_clause) THEN

        l_category_id := FND_FLEX_KEYVAL.combination_id;
    END IF;

    IF (l_category_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_CATEGORY');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    RETURN l_category_id;

END get_category_id;


FUNCTION get_spec_id(p_spec_name IN VARCHAR2, p_org_code IN VARCHAR2)
    RETURN NUMBER IS

    l_spec_id NUMBER;
    l_org_id  NUMBER;

    CURSOR c IS
        SELECT spec_id
        FROM qa_specs
        WHERE spec_name = p_spec_name AND organization_id = l_org_id;

BEGIN

    l_org_id := qa_plans_api.get_org_id(p_org_code);

    OPEN c;
    FETCH c INTO l_spec_id;

    IF c%NOTFOUND THEN
        CLOSE c;
        fnd_message.set_name('QA', 'QA_API_SPEC_NAME_NOT_FOUND');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    CLOSE c;

    RETURN l_spec_id;

END get_spec_id;


FUNCTION spec_exists(p_name IN VARCHAR2)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  qa_specs
        WHERE spec_name = p_name;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END spec_exists;


FUNCTION spec_element_exists(p_spec_id IN VARCHAR2, p_char_id IN NUMBER)
    RETURN BOOLEAN IS

    CURSOR c IS
        SELECT 1
        FROM  qa_spec_chars
        WHERE spec_id = p_spec_id AND char_id = p_char_id;

    result BOOLEAN;
    dummy NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    RETURN result;

END spec_element_exists;


FUNCTION convert_flag(p_flag IN VARCHAR2)
    RETURN NUMBER IS

BEGIN

    IF p_flag = fnd_api.g_true THEN
        RETURN 1;
    END IF;

    RETURN 2;

END convert_flag;


--
-- Global Specifications Enhancements
-- Introduced the following internal functions
-- Both are overloaded for ease of use
--
-- Extremely useful to change the API to support
-- Global Specifications Enhancements
--
-- rkunchal
--
-- is_child_spec returns true if the passed spec is a child spec.
-- child_spec_exists returns true if the passed spec is being
--   referenced by at least one more spec.
--

FUNCTION is_child_spec(p_spec_id IN NUMBER) RETURN BOOLEAN IS

  CURSOR c IS
     SELECT 1
     FROM   qa_specs
     WHERE  spec_id = p_spec_id
     AND    spec_id <> common_spec_id;

  result BOOLEAN;
  dummy  NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO dummy;
  result := c%FOUND;
  CLOSE c;

  RETURN result;

END is_child_spec;

FUNCTION is_child_spec(p_spec_name IN VARCHAR2) RETURN BOOLEAN IS

  CURSOR c IS
     SELECT 1
     FROM   qa_specs
     WHERE  spec_name = p_spec_name
     AND    spec_id <> common_spec_id;

  result BOOLEAN;
  dummy  NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO dummy;
  result := c%FOUND;
  CLOSE c;

  RETURN result;

END is_child_spec;

FUNCTION child_spec_exists(p_spec_id IN NUMBER) RETURN BOOLEAN IS

  CURSOR c IS
     SELECT 1
     FROM   qa_specs
     WHERE  common_spec_id = p_spec_id
     AND    spec_id <> common_spec_id;

  result BOOLEAN;
  dummy  NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO dummy;
  result := c%FOUND;
  CLOSE c;

  RETURN result;

END child_spec_exists;

FUNCTION child_spec_exists(p_spec_name IN VARCHAR2) RETURN BOOLEAN IS

  CURSOR c IS
     SELECT 1
     FROM   qa_specs qs1, qa_specs qs2
     WHERE  qs1.spec_name = p_spec_name
     AND    qs1.spec_id = qs2.common_spec_id
     AND    qs2.spec_id <> qs2.common_spec_id;

  result BOOLEAN;
  dummy  NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO dummy;
  result := c%FOUND;
  CLOSE c;

  RETURN result;

END child_spec_exists;

--
--
--  Start of Public APIs
--

--
-- Add a new argument to pass common_spec_id also.
-- This API can be used to create a referencing spec (child spec) also.
-- Additional validation for a referencing spec is, to check if
-- the referenced spec is a master or not.
--

PROCEDURE create_specification(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2  := fnd_api.g_false,
    p_validation_level          IN  NUMBER    := fnd_api.G_VALID_LEVEL_FULL,
    p_user_name                 IN  VARCHAR2  := NULL,
    p_spec_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_reference_spec            IN  VARCHAR2  := NULL,
    p_effective_from            IN  DATE      := SYSDATE,
    p_effective_to              IN  DATE      := NULL,
    p_assignment_type           IN  NUMBER    := qa_specs_pub.g_spec_type_item,
    p_category_set_name         IN  VARCHAR2  := NULL,
    p_category_name             IN  VARCHAR2  := NULL,
    p_item_name                 IN  VARCHAR2  := NULL,
    p_item_revision             IN  VARCHAR2  := NULL,
    p_supplier_name             IN  VARCHAR2  := NULL,
    p_customer_name             IN  VARCHAR2  := NULL,
    p_sub_type_element          IN  VARCHAR2  := NULL,
    p_sub_type_element_value    IN  VARCHAR2  := NULL,
    x_spec_id                   OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    -- Bug 7430441.FP for Bug 6877858.
    -- Added the attribute parameters in order to populate the DFF
    -- fields too into the qa_specs table
    -- pdube Wed Sep 24 03:17:03 PDT 2008
    p_attribute_category        IN VARCHAR2 := NULL,
    p_attribute1                IN VARCHAR2 := NULL,
    p_attribute2                IN VARCHAR2 := NULL,
    p_attribute3                IN VARCHAR2 := NULL,
    p_attribute4                IN VARCHAR2 := NULL,
    p_attribute5                IN VARCHAR2 := NULL,
    p_attribute6                IN VARCHAR2 := NULL,
    p_attribute7                IN VARCHAR2 := NULL,
    p_attribute8                IN VARCHAR2 := NULL,
    p_attribute9                IN VARCHAR2 := NULL,
    p_attribute10               IN VARCHAR2 := NULL,
    p_attribute11               IN VARCHAR2 := NULL,
    p_attribute12               IN VARCHAR2 := NULL,
    p_attribute13               IN VARCHAR2 := NULL,
    p_attribute14               IN VARCHAR2 := NULL,
    p_attribute15               IN VARCHAR2 := NULL ) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'create_specification_pub';
    l_api_version       CONSTANT NUMBER         := 1.0;

    l_user_id                   NUMBER;
    l_org_id                    NUMBER := -1;
    l_category_set_id           NUMBER := -1;
    l_category_id               NUMBER := -1;
    l_structure_id              NUMBER;
    l_validate_flag             mtl_category_sets.validate_flag%TYPE;
    l_item_id                   NUMBER := -1;
    l_vendor_id                 NUMBER := -1;
    l_customer_id               NUMBER := -1;
    l_char_id                   NUMBER := -1;
    l_sub_type_value            qa_specs.spec_element_value%TYPE;
    l_existing_spec_name        VARCHAR2(30);
    l_datatype                  NUMBER;

    l_reference_spec_id            NUMBER;

    --BUG 3500244
    --we do NOT support ERES in APIs as documented in QA FDA HLD
    --so this should behave as though ERES profile is No
    --which means spec_status of 40 which is No Approval Reqd
    --should be used for spec creation since it is a NON-Null Column
    l_spec_status                  NUMBER := 40;


    CURSOR c IS
      SELECT spec_id
      FROM   qa_specs
      WHERE  spec_name = p_reference_spec;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT create_specification_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    -- Algorithm
    --
    --
    -- 0. Check for duplicate name
    --
    -- 0.5 If the reference_spec is passed, verify if that spec exists and is not a
    --     referencing any other spec.
    --
    -- 1. convert org code to org id
    --
    -- 2. validate the effective FROM and TO dates
    --
    -- 3.
    --    if assignment type is supplier then
    --        validate vendor and generate id
    --    else if assignment type is customer then
    --        validate customer and generate id
    --    end if;
    --
    -- 4.
    --    if item is given then
    --        validate item and generate id
    --        validate revision if provided
    --    else if category set name is given then
    --        validate category set name and generate id
    --    else
    --        generate an error
    --    end if;
    --
    -- 5. if there is spec sub type provided (element) then
    --    convert it into id
    --
    -- 6. Check for existing combination.
    --
    -- 7. generate spec id
    --
    -- 8. insert the row

    IF (spec_exists(p_spec_name)) THEN
        fnd_message.set_name('QA', 'QA_API_DUPLICATE_SPEC_NAME');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    -- See if the spec exists with p_common_spec_name
    IF p_reference_spec IS NOT NULL AND NOT spec_exists(p_reference_spec) THEN
        fnd_message.set_name('QA', 'QA_SPEC_NOT_EXISTS');
        fnd_message.set_token('ENTITY1', p_reference_spec);
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    -- Force not to reference a child spec if common_spec_name is passed
    IF p_reference_spec IS NOT NULL AND is_child_spec(p_reference_spec) THEN
        fnd_message.set_name('QA', 'QA_CANNOT_REFER_CHILD_SPEC');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    l_org_id := qa_plans_api.get_org_id(p_organization_code);

    IF (l_org_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ORG_CODE');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_effective_to IS NOT NULL) THEN
        IF (p_effective_to < p_effective_from) THEN
            fnd_message.set_name('QA', 'QA_EFFECTIVE_DATE_RANGE');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;
    END IF;

    IF (p_assignment_type = g_spec_type_item) THEN
        NULL; -- nothing special needs to be done for item spec.

    ELSIF (p_assignment_type = g_spec_type_supplier) THEN
        l_vendor_id := qa_plan_element_api.get_supplier_id(p_supplier_name);
        IF (l_vendor_id IS NULL) THEN
            fnd_message.set_name('QA', 'QA_API_INVALID_VENDOR_NAME');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    ELSIF (p_assignment_type = g_spec_type_customer) THEN
        l_customer_id := qa_plan_element_api.get_customer_id(p_customer_name);
        IF (l_customer_id IS NULL) THEN
            fnd_message.set_name('QA', 'QA_API_INVALID_CUSTOMER_NAME');
            fnd_msg_pub.add();
            RAISE fnd_api.g_exc_error;
        END IF;

    ELSE
        fnd_message.set_name('QA', 'QA_API_INVALID_ASSIGNMENT_TYPE');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_item_name IS NOT NULL) THEN
        l_item_id := process_item_and_revision(p_item_name, p_item_revision,
            l_org_id);
    ELSE
        l_category_set_id := get_category_set_id(
            p_category_set_name, l_structure_id, l_validate_flag);
        l_category_id := get_category_id(p_category_name,
            l_category_set_id, l_org_id, l_structure_id, l_validate_flag);
    END IF;

    IF (p_sub_type_element IS NOT NULL) THEN
        l_sub_type_value := p_sub_type_element_value;
        l_char_id := qa_chars_api.get_element_id(p_sub_type_element);
 /* Fix for bug 3216242 - Check to ensure sub_type_element is a valid collection element.Hence, l_char_id should be not NULL for valid case.Added the following IF-ELSE condition.
 */
        IF (l_char_id IS NOT NULL) THEN
            l_datatype := qa_chars_api.datatype(l_char_id);
            validate_datatype(l_sub_type_value, l_datatype);
        ELSE
           fnd_message.set_name('QA', 'QA_API_INVALID_ELEMENT');
           fnd_msg_pub.add();
           RAISE fnd_api.g_exc_error;
        END IF;
    ELSE
        l_char_id := -1;
        l_sub_type_value := '-1';
    END IF;

    IF (combination_exists(l_category_set_id, l_category_id, l_item_id,
        p_item_revision, l_org_id, l_vendor_id, l_customer_id, l_char_id,
        l_sub_type_value, l_existing_spec_name)) THEN

        fnd_message.set_name('QA', 'QA_SPEC_COMBINATION_EXISTS');
        fnd_message.set_token('ENTITY1', l_existing_spec_name);
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    SELECT qa_specs_s.nextval INTO x_spec_id FROM DUAL;

    IF p_reference_spec IS NOT NULL THEN
       OPEN c;
       FETCH c INTO l_reference_spec_id;
       CLOSE c;
    ELSE
       l_reference_spec_id := x_spec_id;
    END IF;

    INSERT INTO qa_specs(
        spec_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        spec_name,
        organization_id,
        effective_from,
        effective_to,
        common_spec_id,
        assignment_type,
        category_set_id,
        category_id,
        item_id,
        item_revision,
        vendor_id,
        customer_id,
        hide_plan_chars_flag,
        char_id,
        spec_element_value,
	spec_status,       --Bug 3500244
        attribute_category, -- Bug 7430441
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15 )
    VALUES(
        x_spec_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        p_spec_name,
        l_org_id,
        p_effective_from,
        p_effective_to,
        l_reference_spec_id,
        p_assignment_type,
        l_category_set_id,
        l_category_id,
        l_item_id,
        nvl(p_item_revision, 'NONE'),
        l_vendor_id,
        l_customer_id,
        1,
        l_char_id,
        l_sub_type_value,
	l_spec_status,  --Bug 3500244
        p_attribute_category , -- Bug 7430441
        p_attribute1 ,
        p_attribute2 ,
        p_attribute3 ,
        p_attribute4 ,
        p_attribute5 ,
        p_attribute6 ,
        p_attribute7 ,
        p_attribute8 ,
        p_attribute9 ,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15 );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO create_specification_pub;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO create_specification_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        -- dbms_output.put_line(SQLCODE || SQLERRM);
        ROLLBACK TO create_specification_pub;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END create_specification;

--
-- Adding spec elements is not allowed for child specs
-- We would throw the same error if attempted.
--
-- rkunchal
--

PROCEDURE add_spec_element(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.G_VALID_LEVEL_FULL,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_element_name              IN      VARCHAR2,
    p_uom_code                  IN      VARCHAR2 := NULL,
    p_enabled_flag              IN      VARCHAR2 := fnd_api.g_true,
    p_target_value              IN      VARCHAR2 := NULL,
    p_upper_spec_limit          IN      VARCHAR2 := NULL,
    p_lower_spec_limit          IN      VARCHAR2 := NULL,
    p_upper_reasonable_limit    IN      VARCHAR2 := NULL,
    p_lower_reasonable_limit    IN      VARCHAR2 := NULL,
    p_upper_user_defined_limit  IN      VARCHAR2 := NULL,
    p_lower_user_defined_limit  IN      VARCHAR2 := NULL,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2,
    -- 7430441.FP for Bug 7046198
    -- Added the attribute parameters in order to populate the DFF
    -- fields too into the qa_spec_chars table
    -- pdube Wed Sep 24 03:17:03 PDT 2008
    p_attribute_category        IN VARCHAR2 := NULL,
    p_attribute1                IN VARCHAR2 := NULL,
    p_attribute2                IN VARCHAR2 := NULL,
    p_attribute3                IN VARCHAR2 := NULL,
    p_attribute4                IN VARCHAR2 := NULL,
    p_attribute5                IN VARCHAR2 := NULL,
    p_attribute6                IN VARCHAR2 := NULL,
    p_attribute7                IN VARCHAR2 := NULL,
    p_attribute8                IN VARCHAR2 := NULL,
    p_attribute9                IN VARCHAR2 := NULL,
    p_attribute10               IN VARCHAR2 := NULL,
    p_attribute11               IN VARCHAR2 := NULL,
    p_attribute12               IN VARCHAR2 := NULL,
    p_attribute13               IN VARCHAR2 := NULL,
    p_attribute14               IN VARCHAR2 := NULL,
    p_attribute15               IN VARCHAR2 := NULL ) IS


    l_api_name                  CONSTANT VARCHAR2(30)   := 'add_spec_element';
    l_api_version               CONSTANT NUMBER         := 1.0;

    l_user_id      NUMBER;
    l_enabled_flag NUMBER;
    l_char_id      NUMBER;
    l_spec_id      NUMBER;
    l_datatype     NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT add_spec_element;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_char_id := get_context_element_id(p_element_name);
    l_spec_id := get_spec_id(p_spec_name, p_organization_code);

    -- See if the spec is a child and throw exception appropriately
    IF is_child_spec(l_spec_id) THEN
        fnd_message.set_name('QA', 'QA_SPEC_ELEM_TO_CHILD');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    IF (spec_element_exists(l_spec_id, l_char_id)) THEN
        fnd_message.set_name ('QA', 'QA_API_DUPLICATE_SPEC_ELEMENT');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    l_datatype := qa_chars_api.datatype(l_char_id);

    validate_datatype(p_target_value, l_datatype);
    validate_datatype(p_upper_spec_limit, l_datatype);
    validate_datatype(p_lower_spec_limit, l_datatype);
    validate_datatype(p_upper_reasonable_limit, l_datatype);
    validate_datatype(p_lower_reasonable_limit, l_datatype);
    validate_datatype(p_upper_user_defined_limit, l_datatype);
    validate_datatype(p_lower_user_defined_limit, l_datatype);

    IF qltcompb.compare(p_upper_spec_limit, 6, p_lower_spec_limit, null,
        l_datatype) THEN
        fnd_message.set_name('QA', 'QA_LSL_GREATER_THAN_USL');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF qltcompb.compare(p_upper_reasonable_limit, 6, p_lower_reasonable_limit,
        null, l_datatype) THEN
        fnd_message.set_name('QA', 'QA_LRL_GREATER_THAN_URL');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF qltcompb.compare(p_upper_user_defined_limit, 6,
        p_lower_user_defined_limit, null, l_datatype) THEN
        fnd_message.set_name('QA', 'QA_LUL_GREATER_THAN_UUL');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    l_enabled_flag := convert_flag(p_enabled_flag);

    -- The values getting inserted in to qa_spec_chars in the following insert
    -- statement were reversed.Changed the order of parameters for
    -- upper_reasonable_limit,lower_reasonable_limit,upper_user_defined_limit,
    -- lower_user_defined_limit.
    -- Bug 2715786.suramasw Wed Dec 18 23:08:20 PST 2002.

    INSERT INTO qa_spec_chars(
        spec_id,
        char_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        enabled_flag,
        target_value,
        upper_spec_limit,
        lower_spec_limit,
        upper_reasonable_limit,
        lower_reasonable_limit,
        upper_user_defined_limit,
        lower_user_defined_limit,
        uom_code,
        attribute_category, -- Bug 7430441
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15 )
    VALUES(
        l_spec_id,
        l_char_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        l_enabled_flag,
        p_target_value,
        p_upper_spec_limit,
        p_lower_spec_limit,
        p_upper_reasonable_limit,
        p_lower_reasonable_limit,
        p_upper_user_defined_limit,
        p_lower_user_defined_limit,
        p_uom_code,
        p_attribute_category , -- Bug 7430441
        p_attribute1 ,
        p_attribute2 ,
        p_attribute3 ,
        p_attribute4 ,
        p_attribute5 ,
        p_attribute6 ,
        p_attribute7 ,
        p_attribute8 ,
        p_attribute9 ,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15 );

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO add_spec_element;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO add_spec_element;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        ROLLBACK TO add_spec_element;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END add_spec_element;


PROCEDURE complete_spec_processing(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2) IS

    l_api_name          CONSTANT VARCHAR2(30):= 'complete_spec_definition';
    l_api_version       CONSTANT NUMBER      := 1.0;

    l_user_id   NUMBER;
    l_spec_id   NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT complete_spec_definition;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_spec_id := get_spec_id(p_spec_name, p_organization_code);
    check_for_spec_element(l_spec_id);

    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO complete_spec_definition;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO complete_spec_definition;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        ROLLBACK TO complete_spec_definition;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END complete_spec_processing;


PROCEDURE delete_spec_private(p_spec_id IN NUMBER) IS
--
-- The real work of deleting a specification and all its
-- spec elements.  Do not commit.
--
BEGIN

    DELETE
    FROM qa_spec_chars
    WHERE spec_id = p_spec_id;

    DELETE
    FROM qa_specs
    WHERE spec_id = p_spec_id;

END delete_spec_private;

PROCEDURE delete_spec_element_private(
    p_spec_id IN NUMBER,
    p_element_id IN NUMBER) IS

BEGIN

    DELETE
    FROM qa_spec_chars
    WHERE spec_id = p_spec_id
    AND char_id = p_element_id;

END delete_spec_element_private;


--
-- Should not allow deletion if there exists
-- at least one child spec. Use child_spec_exists
-- rkunchal
--

PROCEDURE delete_specification(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2) IS

    l_api_name                  CONSTANT VARCHAR2(30):= 'delete_specification';
    l_api_version               CONSTANT NUMBER      := 1.0;

    l_user_id      NUMBER;
    l_spec_id      NUMBER;
    l_org_id       NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT   delete_specification;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_spec_id := get_spec_id(p_spec_name, p_organization_code);

    -- Perfect place to check for child specs
    IF child_spec_exists(l_spec_id) THEN
        fnd_message.set_name('QA', 'QA_CHILD_SPECS_EXIST');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    delete_spec_private(l_spec_id);

    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO delete_specification;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO delete_specification;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        ROLLBACK TO delete_specification;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END delete_specification;

--
-- Though this will not effectively do anything for child specs,
-- we want to give an impression to caller that this operation
-- on a child spec is not functionally valid and is discouraged.
--
-- rkunchal
--

PROCEDURE delete_spec_element(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_element_name              IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2) IS

    l_api_name                  CONSTANT VARCHAR2(30):= 'delete_spec_element';
    l_api_version               CONSTANT NUMBER      := 1.0;

    l_user_id   NUMBER;
    l_spec_id   NUMBER;
    l_char_id   NUMBER;
    l_org_id    NUMBER;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT delete_spec_element;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_spec_id := get_spec_id(p_spec_name, p_organization_code);

    -- We must be checking here if the spec is a child
    IF is_child_spec(l_spec_id) THEN
        fnd_message.set_name('QA', 'QA_DELETE_SPEC_ELEM_ON_CHILD');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_char_id := get_context_element_id(p_element_name);

    delete_spec_element_private(l_spec_id, l_char_id);

    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO delete_spec_element;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO delete_spec_element;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        ROLLBACK TO delete_spec_element;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END delete_spec_element;

--
-- We should not copy Spec Elements if the spec being copied is a child.
-- The new, copied spec still references the same master spec.
-- Copying child is seemless and caller will not see any message.
--
-- rkunchal
--

PROCEDURE copy_specification(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_to_spec_name              IN      VARCHAR2,
    p_to_organization_code      IN      VARCHAR2,
    p_to_item_name              IN      VARCHAR2,
    p_to_item_revision          IN      VARCHAR2 := NULL,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_spec_id                   OUT     NOCOPY NUMBER,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2) IS

    l_api_name                  CONSTANT VARCHAR2(30):= 'copy_specification';
    l_api_version               CONSTANT NUMBER      := 1.0;

    l_user_id                   NUMBER;
    l_spec_id                   NUMBER;
    l_org_id                    NUMBER;
    l_spec_name                 NUMBER;
    l_to_org_id                 NUMBER;
    l_category_set_id           NUMBER;
    l_category_id               NUMBER;
    l_to_item_id                NUMBER;
    l_to_item_revision          NUMBER;
    l_vendor_id                 NUMBER;
    l_customer_id               NUMBER;
    l_char_id                   NUMBER;
    l_spec_element_value        VARCHAR2(150);
    l_existing_spec_name        VARCHAR2(30);

    --BUG 3500244
    --we do NOT support ERES in APIs as documented in QA FDA HLD
    --so this should behave as though ERES profile is No
    --which means spec_status of 40 which is No Approval Reqd
    --should be used for spec creation since it is a NON-Null Column

    l_spec_status               NUMBER := 40;

BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT copy_specification;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    l_spec_id := get_spec_id(p_spec_name, p_organization_code);
    l_org_id := organization_id(l_spec_id);

    l_to_org_id := qa_plans_api.get_org_id(p_to_organization_code);
    IF (l_to_org_id IS NULL) THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_ORG_CODE');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (spec_exists(p_to_spec_name)) THEN
        fnd_message.set_name('QA', 'QA_API_DUPLICATE_SPEC_NAME');
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    l_to_item_id := process_item_and_revision(p_to_item_name,
        p_to_item_revision, l_org_id);

    l_category_set_id           := category_set_id(l_spec_id);
    l_category_id               := category_id(l_spec_id);
    l_vendor_id                 := vendor_id(l_spec_id);
    l_customer_id               := customer_id(l_spec_id);
    l_char_id                   := char_id(l_spec_id);
    l_spec_element_value        := spec_element_value(l_spec_id);

    IF (combination_exists(l_category_set_id, l_category_id, l_to_item_id,
        p_to_item_revision, l_org_id, l_vendor_id, l_customer_id, l_char_id,
        l_spec_element_value, l_existing_spec_name)) THEN

        fnd_message.set_name('QA', 'QA_SPEC_COMBINATION_EXISTS');
        fnd_message.set_token('ENTITY1', l_existing_spec_name);
        fnd_msg_pub.add();
        RAISE fnd_api.g_exc_error;
    END IF;

    SELECT qa_specs_s.nextval INTO x_spec_id FROM DUAL;

    INSERT INTO qa_specs(
        spec_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        spec_name,
        organization_id,
        effective_from,
        effective_to,
        common_spec_id,
        assignment_type,
        category_set_id,
        category_id,
        item_id,
        item_revision,
        vendor_id,
        customer_id,
        hide_plan_chars_flag,
        char_id,
        spec_element_value,
        spec_status ) --Bug 3500244
    SELECT
        x_spec_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        p_to_spec_name,
        l_to_org_id,
        effective_from,
        effective_to,
        common_spec_id,
        assignment_type,
        category_set_id,
        category_id,
        l_to_item_id,
        nvl(p_to_item_revision, 'NONE'),
        vendor_id,
        customer_id,
        hide_plan_chars_flag,
        char_id,
        spec_element_value,
        40                 --Bug 3500244 see note below
    FROM qa_specs
    WHERE spec_id = l_spec_id;

    --Bug 3500244
    --In above Select we have not used the variable l_spec_status
    --But purposely used the literal 40 so it is very clear for readability
    --that we are not selecting from database, but it is kind of a constant


    -- Prevent this insertion if the spec being copied is a child spec
    IF NOT is_child_spec(l_spec_id) THEN
      INSERT INTO qa_spec_chars(
        spec_id,
        char_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        enabled_flag,
        target_value,
        upper_spec_limit,
        lower_spec_limit,
        upper_reasonable_limit,
        lower_reasonable_limit,
        upper_user_defined_limit,
        lower_user_defined_limit)
      SELECT
        x_spec_id,
        char_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        enabled_flag,
        target_value,
        upper_spec_limit,
        lower_spec_limit,
        upper_user_defined_limit,
        lower_user_defined_limit,
        upper_reasonable_limit,
        lower_reasonable_limit
      FROM qa_spec_chars
      WHERE spec_id = l_spec_id;
    END IF;

    --
    -- Bug 5231952.  After copying, we should copy attachments.
    --
    qa_specs_pkg.copy_attachment(
        p_from_spec_id => l_spec_id,
        p_to_spec_id => x_spec_id);

    IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO copy_specification;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO copy_specification;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN OTHERS THEN
        ROLLBACK TO copy_specification;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.Add_Exc_Msg(g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END copy_specification;


END qa_specs_pub;


/
