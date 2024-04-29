--------------------------------------------------------
--  DDL for Package Body PO_GMS_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GMS_INTEGRATION_PVT" AS
/* $Header: POXVGMSB.pls 120.5 2005/12/06 16:18:53 vinokris noship $ */

c_log_head    CONSTANT VARCHAR2(40) := 'po.plsql.PO_GMS_INTEGRATION_PVT.';
g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_GMS_INTEGRATION_PVT';


-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base('POXVGMSB');

-- The module base for the subprogram.
D_validate_award_data CONSTANT VARCHAR2(100) :=
	PO_LOG.get_subprogram_base(D_PACKAGE_BASE, 'validate_award_data');

-------------------------------------------------------------------------------
--Start of Comments
--Name: maintain_adl (ADL stands for Award Distribution Lines in Grants)
--Pre-reqs:
--  None.
--Modifies:
--  GMS_AWARD_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  When PO/Req distribution records are created from CopyDoc, Autocreate,
--  PO Release Process, or Change PO, we need to call Grants API to generate
--  new award distribution lines if the parent distribution record
--  references an award.
--Parameters:
--IN:
--p_api_version
--  Specifies the GMS API version.
--p_caller
--  Specifies who the caller is.
--  Possible values for p_caller are:
--  AUTOCREATE, CHANGEPO, COPYDOC, CREATE_RELEASE
--OUT:
--x_return_status
--  Represents the result returned by the GMS API and
--  will have one of the following values:
--     G_RET_STS_SUCCESS    = 'S'
--     G_RET_STS_ERROR      = 'E'
--     G_RET_STS_UNEXP_ERROR= 'U'
--x_msg_count
--  Holds the number of messages in the GMS API message list.
--x_msg_data
--  Holds the error messages returned by the GMS API.
--IN OUT
--x_po_gms_interface_obj
--  Is of type gms_po_interface_type.
--  gms_po_interface_type is a SQL object having the following table
--  elements:
--      distribution_id - Holds distribution id's
--      distribution_num  Holds distribution numbers
--      project_id        Holds Project ID
--      task_id           Holds Task ID
--      award_set_id_in   Holds Award Set Id References
--      award_set_id_out  Holds new award distribution line references
--                        as returned by GMS API's.
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE maintain_adl (
    p_api_version             IN             NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2,
    p_caller                  IN             VARCHAR2,
    x_po_gms_interface_obj    IN OUT NOCOPY  gms_po_interface_type
)
IS
    l_api_name  CONSTANT VARCHAR(30) := 'MAINTAIN_ADL';
    l_progress  VARCHAR2(3);
BEGIN

    l_progress := '000';
    -- Standard Start of API savepoint
    SAVEPOINT maintain_adl_savepoint;

    IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(
              log_level => FND_LOG.LEVEL_STATEMENT,
              module    => c_log_head || l_api_name || '.begin',
              message   => 'Before calling GMS API v.' || p_api_version);
       END IF;

       FOR i IN 1..x_po_gms_interface_obj.distribution_id.COUNT LOOP
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(
              log_level => FND_LOG.LEVEL_STATEMENT,
              module    => c_log_head || l_api_name || '.begin',
              message   => p_caller
                           ||' dist id: '
                           || x_po_gms_interface_obj.distribution_id(i)
                           ||' proj_id : '
                           ||x_po_gms_interface_obj.project_id(i)
                           ||' task_id: '
                           || x_po_gms_interface_obj.task_id(i)
                           ||' award_set_id_in: '
                           ||x_po_gms_interface_obj.award_set_id_in(i));
          END IF;
       END LOOP;
    END IF;

    l_progress := '010';
    GMS_PO_API2_GRP.CREATE_ADLS (
           p_api_version      => p_api_version,
           p_commit           => FND_API.G_FALSE,
           p_init_msg_list    => FND_API.G_TRUE,
           p_validation_level => 100,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           x_return_status    => x_return_status,
           p_calling_module   => p_caller,
           p_interface_obj    => x_po_gms_interface_obj);

    l_progress := '020';
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';
    IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(
              log_level => FND_LOG.LEVEL_STATEMENT,
              module    => c_log_head || l_api_name || '.begin',
              message   => 'After calling GMS API : '
                           || 'return status: '
                           || x_return_status);
       END IF;

       FOR i IN 1..x_po_gms_interface_obj.distribution_id.COUNT LOOP
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(
              log_level => FND_LOG.LEVEL_STATEMENT,
              module    => c_log_head || l_api_name || '.begin',
              message   => p_caller
                           ||' dist num: '
                           || x_po_gms_interface_obj.distribution_num(i)
                           ||' dist id: '
                           || x_po_gms_interface_obj.distribution_id(i)
                           ||' proj_id : '
                           ||x_po_gms_interface_obj.project_id(i)
                           ||' task_id: '
                           || x_po_gms_interface_obj.task_id(i)
                           ||' award_set_id_in: '
                           ||x_po_gms_interface_obj.award_set_id_in(i)
                           ||' award_set_id_out: '
                           ||x_po_gms_interface_obj.award_set_id_out(i));
          END IF;
       END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO maintain_adl_savepoint;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (g_fnd_debug = 'Y') THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(
              LOG_LEVEL => FND_LOG.level_unexpected,
              MODULE    => c_log_head || '.'||l_api_name||'.error_exception',
              MESSAGE   => 'EXCEPTION '||l_progress||': Unexpected Error'
           );
           END IF;
        END IF;

    WHEN OTHERS THEN
        ROLLBACK TO maintain_adl_savepoint;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(p_message_level =>
                                       FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                   p_procedure_name => l_api_name);
        END IF;

        IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
            FND_LOG.string(
            LOG_LEVEL => FND_LOG.level_unexpected,
            MODULE    => c_log_head || '.'||l_api_name||'.error_exception',
            MESSAGE   => 'EXCEPTION '||l_progress||': SQL CODE is '||sqlcode
          );
          END IF;
        END IF;

END maintain_adl;


---------------------------------------------------------------------
-- Function: get_gms_enabled_flag
--
-- Return whether or not Grants are enabled for the specified
-- organization.
--
-- @param p_org_id
-- The organization to check.

-- @return
-- 'Y' if Grants is enabled for the specified organization; 'N' if
-- grants is not enabled for the specified organization.

-- @depends GMS_INSTALL.enabled()
--
---------------------------------------------------------------------
FUNCTION get_gms_enabled_flag(
  p_org_id IN NUMBER
) RETURN VARCHAR2
IS
x_enabled_flag VARCHAR2(1);

BEGIN

x_enabled_flag := 'N';

IF(GMS_INSTALL.enabled(x_org_id => p_org_id)) THEN
  x_enabled_flag := 'Y';
END IF;

RETURN x_enabled_flag;

END get_gms_enabled_flag;


---------------------------------------------------------------------
-- Function: is_gms_enabled
--
-- Returns whether or not Grants is enabled for the organization in
-- the current context.
--
-- @return
-- TRUE if Grants is enabled for the current organization,
-- FALSE if Grants is not enabled for the current organization.
--
-- @depends PO_MOAC_UTILS_PVT.get_current_org_id(),
--          get_gms_enabled_flag()
--
---------------------------------------------------------------------
FUNCTION is_gms_enabled
RETURN BOOLEAN
IS
x_enabled BOOLEAN;
l_current_org_id NUMBER;

BEGIN

x_enabled := FALSE;
l_current_org_id := PO_MOAC_UTILS_PVT.get_current_org_id();

IF('Y' = get_gms_enabled_flag(p_org_id => l_current_org_id)) THEN
  x_enabled := TRUE;
END IF;

RETURN x_enabled;

END is_gms_enabled;


---------------------------------------------------------------------
-- Procedure: validate_award_data
--
-- Call the GMS validation command to ensure that the specified
-- award IDs are valid for the specified project, task, and
-- expenditure data on the specified distributions.
--
-- @param p_dist_id_tbl
-- A table of distribution IDs.
--
-- @param p_project_id_tbl
-- A corresponding table of project IDs.
--
-- @param p_task_id_tbl
-- A corresponding table of task IDs.
--
-- @param p_award_number_tbl
-- A corresponding table of award numbers.
--
-- @param p_expenditure_type_tbl
-- A corresponding table of expenditure types.
--
-- @param p_expenditure_item_date_tbl
-- A corresponding table of expenditure item dates.
--
-- @param x_failure_dist_id_tbl
-- The list of distributions which failed the grants validation.
--
-- @param x_failure_message_tbl
-- The corresponding list of failure messages for each failed distribution.
--
-- @depends get_award_id(),
--          GMS_PO_API_GRP.validate_transaction()
---------------------------------------------------------------------
PROCEDURE validate_award_data(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_project_id_tbl              IN PO_TBL_NUMBER
, p_task_id_tbl                 IN PO_TBL_NUMBER
, p_award_number_tbl            IN PO_TBL_VARCHAR2000
, p_expenditure_type_tbl        IN PO_TBL_VARCHAR30
, p_expenditure_item_date_tbl   IN PO_TBL_DATE
, x_failure_dist_id_tbl         OUT NOCOPY PO_TBL_NUMBER
, x_failure_message_tbl         OUT NOCOPY PO_TBL_VARCHAR4000
)
IS

l_award_id_tbl PO_TBL_NUMBER;
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(1);
l_localized_message VARCHAR2(4000);
l_fnd_index NUMBER;
l_failure_index NUMBER;

BEGIN

x_failure_dist_id_tbl := PO_TBL_NUMBER();
x_failure_message_tbl := PO_TBL_VARCHAR4000();
l_failure_index := 0;

-- Get the corresponding IDs for the supplied award numbers
get_award_id(
  p_award_number_tbl => p_award_number_tbl
, x_award_id_tbl => l_award_id_tbl
);

FOR i IN 1..p_dist_id_tbl.COUNT LOOP

  -- Bug# 4779101: Doing this validation only if project is entered.
  IF(p_project_id_tbl(i) IS NOT NULL) THEN
    GMS_PO_API_GRP.validate_transaction(
      p_api_version           => 1.0
    , p_commit                => FND_API.G_FALSE
    , p_init_msg_list         => FND_API.G_TRUE
    , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , x_return_status         => l_return_status
    , p_project_id            => p_project_id_tbl(i)
    , p_task_id               => p_task_id_tbl(i)
    , p_award_id              => l_award_id_tbl(i)
    , p_expenditure_type      => p_expenditure_type_tbl(i)
    , p_expenditure_item_date => p_expenditure_item_date_tbl(i)
    , p_calling_module        => D_validate_award_data
    );

    IF (NVL(l_return_status,'X') <> FND_API.G_RET_STS_SUCCESS) THEN

      FND_MSG_PUB.reset();
      x_failure_dist_id_tbl.extend(l_msg_count);
      x_failure_message_tbl.extend(l_msg_count);

      FOR j in 1..l_msg_count LOOP
        FND_MSG_PUB.get(
          p_msg_index     => FND_MSG_PUB.G_NEXT
        , p_encoded       => FND_API.G_FALSE
        , p_data          => l_localized_message
        , p_msg_index_out => l_fnd_index
        );

        l_failure_index := l_failure_index + 1;
        x_failure_dist_id_tbl(l_failure_index) := p_dist_id_tbl(i);
        x_failure_message_tbl(l_failure_index) := l_localized_message;

      END LOOP;

    END IF;
  END IF;
END LOOP; -- END FOR i IN 1..p_dist_id_tbl.COUNT

END validate_award_data;


---------------------------------------------------------------------
-- Procedure: get_award_id
--
-- A bulk function which converts the Award Number strings in
-- the p_award_number_tbl table to GMS award set IDs, which it
-- places in the x_award_id_tbl.
--
-- @param p_award_number_tbl
-- A table of award number strings.
--
-- @param x_award_id_tbl
-- The GMS award set IDs corresponding to the input award numbers.
--
-- @depends GMS_PO_API_GRP.get_award_id()
---------------------------------------------------------------------
PROCEDURE get_award_id(
  p_award_number_tbl IN PO_TBL_VARCHAR2000
, x_award_id_tbl     OUT NOCOPY PO_TBL_NUMBER
)
IS
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(1);

BEGIN

IF p_award_number_tbl IS NOT NULL THEN

  x_award_id_tbl := PO_TBL_NUMBER();
  x_award_id_tbl.extend(p_award_number_tbl.COUNT);

  FOR i IN 1 .. p_award_number_tbl.COUNT LOOP
    IF(p_award_number_tbl(i) IS NOT NULL) THEN
      x_award_id_tbl(i) :=
        GMS_PO_API_GRP.get_award_id(
          p_api_version         => 1.0
        , p_commit              => FND_API.G_FALSE
        , p_init_msg_list       => FND_API.G_TRUE
        , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
        , x_msg_count           => l_msg_count
        , x_msg_data            => l_msg_data
        , x_return_status       => l_return_status
        , p_award_number        => p_award_number_tbl(i)
        );

      IF (NVL(l_return_status,'X') <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF; -- end p_award_number_tbl(i) IS NOT NULL

  END LOOP; -- end for i in 1 .. p_award_number_tbl.COUNT
END IF; -- end if p_award_number_tbl IS NOT NULL

END get_award_id;


---------------------------------------------------------------------
-- Procedure: maintain_po_adl
--
-- Updates the award set ID after a DML operation.
--
-- @param p_dml_operation
-- Indicates which type of DML operaiotn is being performed.
-- Use the c_DML_OPERATION_* constants.  If there is any
-- uncertainty, UPDATE should be used, as UPDATE will also
-- handle INSERT and DELETE cases, but performs extra
-- processing for INSERT.
--
-- @param p_dist_id
-- The ID of the distribution to update.
--
-- @param p_award_number
-- The current award number on the distribution.
--
-- @param p_project_id
-- The project on the distribution.
--
-- @param p_task_id
-- The task on the distribution.
--
-- @param x_award_set_id
-- The new award set ID for the specified distribution.
--
-- @depends GMS_PO_API_GRP.update_po_adl()
---------------------------------------------------------------------
PROCEDURE maintain_po_adl(
  p_dml_operation       IN VARCHAR2
, p_dist_id             IN NUMBER
, p_award_number        IN VARCHAR2
, p_project_id          IN NUMBER
, p_task_id             IN NUMBER
, x_award_set_id        OUT NOCOPY NUMBER
)
IS
l_old_award_set_id NUMBER := NULL;
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(1);

BEGIN

IF (NVL(p_dml_operation,c_DML_OPERATION_UPDATE) <> c_DML_OPERATION_INSERT) THEN

  BEGIN
    SELECT DIST.award_id
      INTO l_old_award_set_id
      FROM PO_DISTRIBUTIONS_ALL DIST
     WHERE DIST.po_distribution_id = p_dist_id
    ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- If the distribution has not been saved, then it should not have
    -- any award distributions previously created.
    l_old_award_set_id := NULL;
  END;

END IF;

GMS_PO_API_GRP.maintain_po_adl(
  p_api_version         => 1.0
, p_commit              => FND_API.G_FALSE
, p_init_msg_list       => FND_API.G_TRUE
, p_validation_level    => FND_API.G_VALID_LEVEL_FULL
, x_msg_count           => l_msg_count
, x_msg_data            => l_msg_data
, x_return_status       => l_return_status
, p_award_set_id_in     => l_old_award_set_id
, p_project_id          => p_project_id
, p_task_id             => p_task_id
, p_award_number        => p_award_number
, p_po_distribution_id  => p_dist_id
, x_award_set_id_out    => x_award_set_id
);

IF(NVL(l_return_status,'X') <> FND_API.G_RET_STS_SUCCESS) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION
       WHEN OTHERS THEN
    	    FND_MSG_PUB.count_and_get ( p_encoded => fnd_api.g_false,
                                        p_count   => l_msg_count ,
    					p_data    => l_msg_data ) ;

END maintain_po_adl;


---------------------------------------------------------------------
-- Function: get_number_from_award_set_id
--
-- Uses a GMS API to get the award number from the specified
-- award set ID.
--
-- @param p_award_set_id
-- The award set ID to get the display number for.
--
-- @return
-- The displayed award number for the specified ID.
--
-- @depends GMS_PO_API_GRP.get_award_number()
---------------------------------------------------------------------
FUNCTION get_number_from_award_set_id(
  p_award_set_id IN NUMBER
) RETURN VARCHAR2
IS
x_award_number GMS_AWARDS_ALL.award_number%TYPE := NULL;
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(1);

BEGIN

IF (p_award_set_id IS NOT NULL) THEN
  x_award_number :=
    GMS_PO_API_GRP.get_award_number(
      p_api_version         => 1.0
    , p_commit              => FND_API.G_FALSE
    , p_init_msg_list       => FND_API.G_TRUE
    , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
    , x_msg_count           => l_msg_count
    , x_msg_data            => l_msg_data
    , x_return_status       => l_return_status
    , p_award_set_id        => p_award_set_id
    );
END IF;

IF (NVL(l_return_status,'X') <> FND_API.G_RET_STS_SUCCESS) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

RETURN(x_award_number);

END get_number_from_award_set_id;


---------------------------------------------------------------------
-- Procedure: is_award_required_for_project
--
-- Specifies whether or not an award is required for distributions
-- associated with a project with the specified ID.
--
-- @param p_project_id
-- The project ID.
--
-- @param x_award_required_flag
-- 'Y' if the award is required, 'N' if it is not.
--
-- @depends GMS_PO_API_GRP.sponsored_project()
---------------------------------------------------------------------
PROCEDURE is_award_required_for_project(
  p_project_id          IN NUMBER
, x_award_required_flag OUT NOCOPY VARCHAR2
)
IS
BEGIN

x_award_required_flag := 'N';

IF(p_project_id IS NOT NULL) THEN
  x_award_required_flag :=
    GMS_PO_API_GRP.is_sponsored_project(p_project_id => p_project_id);
END IF;

END is_award_required_for_project;

END PO_GMS_INTEGRATION_PVT;

/
