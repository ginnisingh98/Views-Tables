--------------------------------------------------------
--  DDL for Package PAY_DK_TC_DP_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_TC_DP_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pydktaxu.pkh 120.1.12010000.1 2008/07/27 22:27:34 appldev ship $ */



   PROCEDURE upload(
      errbuf                     OUT NOCOPY   VARCHAR2,
      retcode                    OUT NOCOPY   NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL	,
      p_reference                IN       VARCHAR2 DEFAULT NULL
   );




   PROCEDURE read_record
	        (
		 p_line     IN VARCHAR2
		,p_entry_value1   OUT NOCOPY VARCHAR2
		,p_entry_value2   OUT NOCOPY VARCHAR2
		,p_entry_value3   OUT NOCOPY VARCHAR2
		,p_entry_value4   OUT NOCOPY VARCHAR2
		,p_entry_value5   OUT NOCOPY VARCHAR2
		,p_entry_value6   OUT NOCOPY VARCHAR2
		,p_entry_value7   OUT NOCOPY VARCHAR2
		,p_entry_value8   OUT NOCOPY VARCHAR2
		,p_entry_value9   OUT NOCOPY VARCHAR2
		,p_entry_value10  OUT NOCOPY VARCHAR2
		,p_entry_value11  OUT NOCOPY VARCHAR2
		,p_entry_value12  OUT NOCOPY VARCHAR2
		,p_entry_value13  OUT NOCOPY VARCHAR2
		,p_entry_value14  OUT NOCOPY VARCHAR2
		,p_entry_value15  OUT NOCOPY VARCHAR2
		,p_return_value1  OUT NOCOPY VARCHAR2
		,p_return_value2  OUT NOCOPY VARCHAR2
		,p_return_value3  OUT NOCOPY VARCHAR2
		);


FUNCTION get_element_link_id
	(
	 p_assignment_id     IN NUMBER
	,p_business_group_id IN NUMBER
	,p_date              IN per_all_assignments_f.effective_start_date%TYPE
	,p_element_name pay_element_types_f.ELEMENT_NAME%TYPE
	) RETURN NUMBER ;


END pay_dk_tc_dp_upload;


/
