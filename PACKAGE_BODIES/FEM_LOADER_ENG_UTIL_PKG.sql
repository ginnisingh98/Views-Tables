--------------------------------------------------------
--  DDL for Package Body FEM_LOADER_ENG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_LOADER_ENG_UTIL_PKG" AS
-- $Header: fem_ldr_eng_utl.plb 120.0 2006/02/08 11:54:51 gcheng noship $

--
-- Private package constnats and exceptions
--

G_SUCCESS                 CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
G_ERROR                   CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
G_UNEXP                   CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
G_PKG_NAME                CONSTANT VARCHAR2(30) := 'FEM_LOADER_ENG_UTIL_PKG';

G_SNAPSHOT                CONSTANT VARCHAR2(1)  := 'S';
G_INCREMENTAL             CONSTANT VARCHAR2(1)  := 'I';
G_REPLACEMENT             CONSTANT VARCHAR2(1)  := 'R';
G_ERROR_REPROCESSING      CONSTANT VARCHAR2(1)  := 'E';
G_DIM_MEMBER_LOADER       CONSTANT VARCHAR2(30) := 'DIM_MEMBER_LOADER';
G_DIM_HIER_LOADER         CONSTANT VARCHAR2(30) := 'HIERARCHY_LOADER';
G_XGL_LOADER              CONSTANT VARCHAR2(30) := 'XGL_INTEGRATION';
G_FACT_DATA_LOADER        CONSTANT VARCHAR2(30) := 'SOURCE_DATA_LOADER';

E_UNEXP                   EXCEPTION;


-- =========================================================================
PROCEDURE Get_Dim_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   x_exec_mode       OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Determines the Execution Mode that should be passed
--    to the ***Dimension Member Loader*** given the dimension
--    that is being loaded.
-- History
--    01-17-06  G Cheng    Created
-- Arguments
--    p_dimension_id       Dimension identifier
--    x_exec_mode          Loader Execution Mode
-- Logic
--    This procedure will always return 'E' (Error Reprocessing)
--    so both "new" rows and "error" dimension rows will always be loaded.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_loader_eng_util_pkg.get_dim_loader_exec_mode';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Dim_Loader_Exec_Mode';
--
  v_count             NUMBER;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := G_UNEXP;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (G_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||G_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Make sure the dimension is supported by the Dimension Member Loader
  SELECT count(*)
  INTO v_count
  FROM fem_xdim_dimensions
  WHERE dimension_id = p_dimension_id
  AND loader_object_def_id IS NOT NULL;

  IF v_count = 0 THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Dimension ID ('||p_dimension_id
          ||') is not supported by the Dimension Member Loader!');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- For the Dimension Member Loader, always load as Error Reprocessing
  x_exec_mode := G_ERROR_REPROCESSING;

  x_return_status := G_SUCCESS;

  IF (p_commit = G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := G_UNEXP;
--
END Get_Dim_Loader_Exec_Mode;

-- =========================================================================
PROCEDURE Get_Hier_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   p_hierarchy_name  IN VARCHAR2,
   x_exec_mode       OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Determines the Execution Mode that should be passed
--    to the ***Dimension Hierarchy Loader*** given the dimension
--    of the hierarchy and the hierarchy name being loaded.
-- History
--    01-17-06  G Cheng    Created
-- Arguments
--    p_dimension_id       Dimension identifier
--    p_hierarchy_name     Dimension Hierarchy Name
--    x_exec_mode          Loader Execution Mode
-- Logic
--    This procedure will always return 'E' (Error Reprocessing)
--    so both "new" rows and "error" dimesion rows will always be loaded.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_loader_eng_util_pkg.get_hier_loader_exec_mode';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Hier_Loader_Exec_Mode';
--
  v_count             NUMBER;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := G_UNEXP;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (G_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||G_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Make sure the Object ID is a Dimension Hierarchy Loader object type
  SELECT count(*)
  INTO v_count
  FROM fem_xdim_dimensions
  WHERE dimension_id = p_dimension_id
  AND composite_dimension_flag = 'N'
  AND hierarchy_table_name IS NOT NULL
  AND read_only_flag = 'N';

  IF v_count = 0 THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Dimension ID ('||p_dimension_id
          ||') is not supported by the Dimension Hierarchy Loader!');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- For the Dimension Member Loader, always load as Error Reprocessing
  x_exec_mode := G_ERROR_REPROCESSING;

  x_return_status := G_SUCCESS;

  IF (p_commit = G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := G_UNEXP;
--
END Get_Hier_Loader_Exec_Mode;


-- =========================================================================
PROCEDURE Get_XGL_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_cal_period_id   IN NUMBER,
   p_ledger_id       IN NUMBER,
   p_dataset_code    IN NUMBER,
   x_exec_mode       OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Determines the Execution Mode that should be passed
--    to the ***XGL Loader*** given the cal period, ledger and dataset.
-- History
--    01-17-06  G Cheng    Created
-- Arguments
--    p_cal_period_id      Calendar Period ID
--    p_ledger_id          Ledger ID
--    p_dataset_code       Dataset Code
--    x_exec_mode          Loader Execution Mode
-- Logic
--    Return 'S' (Snapshot) if the XGL Loader has not yet had a successful
--    Snapshot execution for the given calendar period, ledger and dataset.
--    Otherwise, return 'I' (Incremental).
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_loader_eng_util_pkg.get_xgl_loader_exec_mode';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_XGL_Loader_Exec_Mode';
  C_XGL_OBJECT_ID    CONSTANT NUMBER(9) := 1000;
--
  v_count             NUMBER;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := G_UNEXP;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (G_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||G_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- See if the XGL Loader has loaded data successfully in Snapshot mode
  -- for the given cal period, ledger and dataset.
  SELECT COUNT(*)
  INTO v_count
  FROM fem_pl_requests r,
       fem_pl_object_executions o
  WHERE r.cal_period_id       = p_cal_period_id
    AND r.ledger_id           = p_ledger_id
    AND r.output_dataset_code = p_dataset_code
    AND r.exec_mode_code      = G_SNAPSHOT
    AND r.exec_status_code    = 'SUCCESS'
    AND o.request_id          = r.request_id
    AND o.object_id           = C_XGL_OBJECT_ID;

  -- If the loader has not yet successfully loaded data in Snapshot mode
  -- for a given parameter set, run in Snapshot mode.
  -- Otheriwse, run in Incremental mode.
  IF (v_count = 0) THEN
    x_exec_mode := G_SNAPSHOT;
  ELSE
    x_exec_mode := G_INCREMENTAL;
  END IF;

  x_return_status := G_SUCCESS;

  IF (p_commit = G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := G_UNEXP;
--
END Get_XGL_Loader_Exec_Mode;


-- =========================================================================
PROCEDURE Get_Fact_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_cal_period_id   IN NUMBER,
   p_ledger_id       IN NUMBER,
   p_dataset_code    IN NUMBER,
   p_source_system_code IN NUMBER,
   p_table_name      IN VARCHAR2,
   x_exec_mode       OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Determines the Execution Mode that should be passed to the
--    ***Fact Data Loader*** given the cal period, ledger, dataset,
--    source system and table.
-- History
--    01-17-06  G Cheng    Created
-- Arguments
--    p_cal_period_id      Calendar Period ID
--    p_ledger_id          Ledger ID
--    p_dataset_code       Dataset Code
--    p_source_system_code Source System Code
--    p_table_name         Table Name
--    x_exec_mode          Loader Execution Mode
-- Logic
--    Return 'S' (Snapshot) if the Fact Data Loader has not yet processed
--    any rows for the given calendar period, ledger,
--    dataset, source system and table.
--    Otherwise, return 'R' (Replacement).
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_loader_eng_util_pkg.get_fact_loader_exec_mode';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Fact_Loader_Exec_Mode';
--
  v_count             NUMBER;
  v_object_id         FEM_OBJECT_CATALOG_B.object_id%TYPE;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := G_UNEXP;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (G_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||G_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE E_UNEXP;
  END IF;

  -- --------------------------------------------------------------------
  -- Validate the Object Definition ID engine parameter by making sure it
  -- exists or is an old approved copy.
  -- Bug 4107295: Check for folder security.
  -- Bug 3995222: Rely on FEM_DATA_LOADER_OBJECTS to determine the relationship
  -- between loader objects and the tables being loaded.
  -- --------------------------------------------------------------------
  BEGIN
    SELECT o.object_id
    INTO v_object_id
    FROM fem_object_catalog_b o, fem_data_loader_objects d
    WHERE o.object_type_code = G_FACT_DATA_LOADER
    AND d.object_id = o.object_id
    AND d.table_name = p_table_name;
  EXCEPTION
    WHEN no_data_found THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNALL ERROR: Could not find the Object ID'
            ||' associated with the '||p_table_name|| ' table!');
      END IF;
      RAISE E_UNEXP;
  END;

  -- See if the Fact Data Loader has already processed at least one row
  -- for the given cal period, ledger, dataset, source system and table.
  SELECT COUNT(*)
  INTO v_count
  FROM fem_pl_requests r,
       fem_pl_object_executions o,
       fem_pl_tables t
  WHERE r.cal_period_id       = p_cal_period_id
    AND r.ledger_id           = p_ledger_id
    AND r.output_dataset_code = p_dataset_code
    AND r.source_system_code  = p_source_system_code
    AND r.table_name          = p_table_name
    AND o.request_id          = r.request_id
    AND t.request_id          = o.request_id
    AND t.object_id           = o.object_id
    AND (t.num_of_output_rows > 0
      OR o.errors_reported    > 0)
    AND o.object_id           = v_object_id;

  -- If the loader has not yet processed any rows for a
  -- given parameter set, run in Snapshot mode.
  -- Otheriwse, run in Replacement mode.
  IF (v_count = 0) THEN
    x_exec_mode := G_SNAPSHOT;
  ELSE
    x_exec_mode := G_REPLACEMENT;
  END IF;

  x_return_status := G_SUCCESS;

  IF (p_commit = G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := G_UNEXP;
--
END Get_Fact_Loader_Exec_Mode;

--
END FEM_LOADER_ENG_UTIL_PKG;

/
