--------------------------------------------------------
--  DDL for Package QLTCONTB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTCONTB" AUTHID CURRENT_USER as
/* $Header: qltcontb.pls 115.3 2002/11/27 19:23:20 jezheng ship $ */

-- 3/19/96 - CREATED
-- Jacqueline Chang

--  This is the procedure that does the processing and computation of
--  new data points to graph, as well as new control limits.


   PROCEDURE X_BAR_R (sql_string VARCHAR2,
			subgrp_size NUMBER,
			num_subgroups IN OUT NOCOPY NUMBER,
			dec_prec NUMBER,
			grand_mean IN OUT NOCOPY NUMBER,
			range_average IN OUT NOCOPY NUMBER,
			UCL OUT NOCOPY NUMBER,
			LCL OUT NOCOPY NUMBER,
			R_UCL OUT NOCOPY NUMBER,
			R_LCL OUT NOCOPY NUMBER,
			not_enough_data OUT NOCOPY NUMBER,
			compute_new_limits IN BOOLEAN default FALSE);

   PROCEDURE X_BAR_S (sql_string VARCHAR2,
			subgrp_size NUMBER,
			num_subgroups IN OUT NOCOPY NUMBER,
			dec_prec NUMBER,
			grand_mean IN OUT NOCOPY NUMBER,
			std_dev_average IN OUT NOCOPY NUMBER,
			UCL OUT NOCOPY NUMBER,
			LCL OUT NOCOPY NUMBER,
			R_UCL OUT NOCOPY NUMBER,
			R_LCL OUT NOCOPY NUMBER,
			not_enough_data OUT NOCOPY NUMBER,
			compute_new_limits IN BOOLEAN default FALSE);


   PROCEDURE XmR (sql_string VARCHAR2,
		subgrp_size NUMBER,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		grand_mean IN OUT NOCOPY NUMBER,
		range_average IN OUT NOCOPY NUMBER,
		UCL OUT NOCOPY NUMBER,
		LCL OUT NOCOPY NUMBER,
		R_UCL OUT NOCOPY NUMBER,
		R_LCL OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER,
		compute_new_limits IN BOOLEAN default FALSE);

   PROCEDURE mXmR (sql_string VARCHAR2,
		subgrp_size NUMBER,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		grand_mean IN OUT NOCOPY NUMBER,
		range_average IN OUT NOCOPY NUMBER,
		UCL OUT NOCOPY NUMBER,
		LCL OUT NOCOPY NUMBER,
		R_UCL OUT NOCOPY NUMBER,
		R_LCL OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER,
		compute_new_limits IN BOOLEAN default FALSE);

  PROCEDURE HISTOGRAM (sql_string VARCHAR2,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		num_bars IN OUT NOCOPY NUMBER,
		USL IN NUMBER,
		LSL IN NUMBER,
		cp IN OUT NOCOPY NUMBER,
		cpk IN OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER);

  -- Bug 2459633. This function added.
  -- rponnusa Mon Jul 15 04:31:49 PDT 2002

  FUNCTION validate_query(p_query_str IN VARCHAR2,
		x_error_num OUT NOCOPY NUMBER)
    RETURN VARCHAR2;


END QLTCONTB;


 

/
