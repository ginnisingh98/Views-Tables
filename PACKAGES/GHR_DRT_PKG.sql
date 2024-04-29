--------------------------------------------------------
--  DDL for Package GHR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ghdrtdrc.pkh 120.0.12010000.3 2018/04/12 09:13:09 poswain noship $ */

 TYPE process_record_type IS RECORD (person_id    NUMBER(15)
                                     ,entity_type  VARCHAR2(3)
                                     ,status       VARCHAR2(1)
                                     ,msgcode      VARCHAR2(30)
                                     ,msgaplid     NUMBER(15));

TYPE result_tbl_type IS TABLE OF process_record_type
 INDEX BY BINARY_INTEGER;

g_process_tbl 			result_tbl_type;

  PROCEDURE write_log
    (message      IN    VARCHAR2
	,stage		  IN	VARCHAR2);

  PROCEDURE add_to_results
    (person_id       IN     NUMBER
	,entity_type	 IN		VARCHAR2
	,status 		 IN		VARCHAR2
	,msgcode		 IN		VARCHAR2
	,msgaplid		 IN		NUMBER
	,result_tbl    	 IN OUT NOCOPY per_drt_pkg.result_tbl_type);

--
-- --------------------------------------------------------------------------------------
--|-----------------------------< GHR_HR_DRC >-------------------------------------------|
-- --------------------------------------------------------------------------------------
-- Description:
-- This procedure checks for the following data removal constraint for HR person type
--
-- DRC: If a future dated RPA exists for an ex-employee, do not remove/mask
--      this person.
-- If this condition satisfies then raise a DRC error. If not, allow the records
-- for this person to be processed.
--
-- ---------------------------------------------------------------------------------------
--

PROCEDURE ghr_hr_drc
		  (person_id	 IN	 NUMBER
		  ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
		  );

--
-- --------------------------------------------------------------------------------------
--|-----------------------------< GHR_FND_DRC >-------------------------------------------|
-- --------------------------------------------------------------------------------------
-- Description:
-- This procedure checks for the following data removal constraint for FND person type
--
-- DRC: If a future dated RPA exists for an ex-employee, do not remove/mask
--      this person.
-- If this condition satisfies then raise a DRC error. If not, allow the records
-- for this person to be processed.
--
-- ---------------------------------------------------------------------------------------
--

PROCEDURE ghr_fnd_drc
		  (person_id	 IN	 NUMBER
		  ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
		  );

--
-- ---------------------------------------------------------------------------
-- |---------------------------< OVERWRITE_DATE>-----------------------------|
-- ---------------------------------------------------------------------------
-- Description:
--  This user-defined function overwrites DATE type PII data present in the
--  columns.
--
-- ---------------------------------------------------------------------------
--
FUNCTION overwrite_date
    (rid         IN ROWID
    ,table_name  IN VARCHAR2
    ,column_name IN VARCHAR2
    ,person_id   IN NUMBER) RETURN VARCHAR2;


----------------------------------------------------------------------------
END GHR_DRT_PKG;

/
