--------------------------------------------------------
--  DDL for Package PAY_GRADE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GRADE_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: pygrr01t.pkh 115.12 2003/06/01 12:14:18 kjagadee ship $ */


 PROCEDURE CHECK_UNIQUENESS(P_GRADE_RULE_ID_2       IN OUT NOCOPY     NUMBER,
                           P_GRADE_OR_SPINAL_POINT_ID          NUMBER,
			   P_RATE_TYPE			       VARCHAR2,
		           P_RATE_ID			       NUMBER,
			   P_BUSINESS_GROUP_ID	               NUMBER,
			   P_MODE		               VARCHAR2);

procedure pop_flds(p_name IN OUT NOCOPY VARCHAR2,
                   p_rt_id IN NUMBER,
                   p_mean IN OUT NOCOPY VARCHAR2,
                   p_bgroup_id IN NUMBER);

-- ----------------------------------------------------------------------------
-- |-------------------< INSERT_ROW >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will insert the grade rule details
--
-- Prerequisites:
--   A valid grade must be existing .
--
-- In Parameters:
--   Name                          Reqd  Type          Description
--   P_GRADE_RULE_ID               yes   number        System assigned id for
--                                                     the grade rule
--   P_EFFECTIVE_START_DATE        yes   date          Start date of this
--                                                     grade rule
--   P_EFFECTIVE_END_DATE          yes   date          End date of this grade
--                                                     rule(maximum date or
--                                                     the end date of
--                                                     attached grade,
--                                                     whichever is earlier)
--  P_GRADE_OR_SPINAL_POINT_ID     yes   date          Grade id which is
--                                                     attached to this grade
--                                                     rule
-- Post Success:
--   Rowid of the new record will be rturned.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal developement use.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
 PROCEDURE INSERT_ROW(P_ROWID IN OUT NOCOPY     	        	 VARCHAR2,
 		      P_GRADE_RULE_ID                            NUMBER,
	              P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2);

 PROCEDURE UPDATE_ROW(P_ROWID            	        	 VARCHAR2,
 		      P_GRADE_RULE_ID                            NUMBER,
	              P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2);

 PROCEDURE DELETE_ROW(P_ROWID                                    VARCHAR2);
--
 PROCEDURE LOCK_ROW( P_ROWID            	        	 VARCHAR2,
 		      P_GRADE_RULE_ID                            NUMBER,
	              P_EFFECTIVE_START_DATE                     DATE,
                      P_EFFECTIVE_END_DATE                       DATE,
                      P_BUSINESS_GROUP_ID                        NUMBER,
                      P_RATE_TYPE                                VARCHAR2,
                      P_GRADE_OR_SPINAL_POINT_ID                 NUMBER,
                      P_RATE_ID                                  NUMBER,
                      P_MAXIMUM                                  VARCHAR2,
                      P_MID_VALUE                                VARCHAR2,
                      P_MINIMUM                                  VARCHAR2,
                      P_SEQUENCE                                 NUMBER,
                      P_VALUE                                    VARCHAR2,
                      P_REQUEST_ID                               NUMBER,
                      P_PROGRAM_APPLICATION_ID                   NUMBER,
                      P_PROGRAM_ID                               NUMBER,
                      P_PROGRAM_UPDATE_DATE                      DATE,
                      P_CURRENCY_CODE                            VARCHAR2);

FUNCTION POPULATE_RATE(p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR;

FUNCTION POPULATE_VALUE(p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR;

FUNCTION POPULATE_UNITS (p_spinal_point_id IN NUMBER, p_effective_date IN DATE)

RETURN VARCHAR;

-- Bug fix 2651173
-- ----------------------------------------------------------------------------
-- |-------------------< chk_emp_asgmnt_bef_del >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure will check that, for the given spinal point id and
--  and parent spine id, point value is used in employee assignments
--  based on the effective date and irrespective of the efective date
--
-- Prerequisites:
--   A valid grade point value should be existing
--
-- In Parameters:
--   Name                          Reqd  Type          Description
--   p_spinal_point_id             yes   number        System assigned id for
--                                                     grade point or spinal
--                                                     point
--   p_parent_spine_id             yes   number        Pay Scale id for the
--                                                     grade points
--   p_effective_date              yes   date          Effective date of the
--                                                     user environment
-- Post Success:
--   p_point_used                        varchar2      Flag used to identify
--                                                     whether the point value
--                                                     is associated with
--                                                     any assignment/s
--                                                     irrespective of the
--                                                     effective date
--   User will be stopped from deleting the point value which is
--   associated with an employee assignment
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal developement use.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_emp_asgmnt_bef_del(p_spinal_point_id in number,
                                 p_parent_spine_id in number,
                                 p_effective_date in date,
                                 p_point_used out nocopy varchar2);
--

END PAY_GRADE_RULES_PKG;

 

/
