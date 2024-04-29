--------------------------------------------------------
--  DDL for Package GL_PERIOD_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PERIOD_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: gliprpts.pls 120.6 2005/05/05 01:18:19 kvora ship $ */
--
-- Package
--   gl_period_types_pkg
-- Purpose
--   To contain validation and insertion routines for gl_period_types
-- History
--   11-02-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the user_period_type, year_type_in_name, and
  --   number_per_fiscal_year for a given period type.
  -- History
  --   11-02-93  D. J. Ogg    Created
  -- Arguments
  --   x_period_type			Period Type to be used
  --   x_user_period_type		User name for the period type
  --   x_year_type_in_name		Calendar or Fiscal period
  --   x_number_per_fiscal_year 	Number of periods of the given
  --				        type in a fiscal year
  -- Example
  --   gl_period_types_pkg.select_columns('Month', user_name, year_type,
  --                                      num_per_year)
  -- Notes
  --
  PROCEDURE select_columns(
			x_period_type			IN OUT NOCOPY VARCHAR2,
  			x_user_period_type		IN OUT NOCOPY VARCHAR2,
			x_year_type_in_name	 	IN OUT NOCOPY VARCHAR2,
			x_number_per_fiscal_year	IN OUT NOCOPY NUMBER);

  --
  -- Procedure
  --   Check_Unique_User_Type
  -- Purpose
  --   Verify user defined period types are unique
  -- History
  --   19-AUG-94   E Wilson
  -- Arguments
  --   x_user_period_type		User name for the period type
  --   x_row_id				Row id
  -- Example
  --   gl_period_types_pkg.check_unique_user_type('Month', <rowid>)
  -- Notes
  --
  PROCEDURE check_unique_user_type(x_user_period_type	VARCHAR2,
				   x_rowid		VARCHAR2);

  --
  -- Procedure
  --   Check_Unique_Type
  -- Purpose
  --   Check that sequence value GL_PERIOD_TYPES_S is unique for each new
  --   period type
  -- History
  --   19-AUG-94     E Wilson      Created
  -- Arguments
  --   x_period_type			System generated Period Type
  --   x_rowid				Rowid
  -- Example
  --   gl_period_types_pkg.check_unique_type('Month', <rowid>)
  -- Notes
  --
  PROCEDURE check_unique_type(x_period_type	VARCHAR2,
  			      x_rowid		VARCHAR2);

  --
  -- Procedure
  --   get_new_id
  -- Purpose
  --   Get unique system value for newly defined period type from seqence
  --   GL_PERIOD_TYPES_S
  -- History
  --   19-AUG-94     E Wilson      Created
  -- Arguments
  --   x_period_type			System generated Period Type
  --   x_rowid				Rowid
  -- Example
  --   gl_period_types_pkg.get_new_id(:PERIOD_TYPES.period_type);
  -- Notes
  --
  PROCEDURE Get_New_Id(x_period_type IN OUT NOCOPY VARCHAR2);



  --
  -- Procedure
  --  translate_row
  -- Purpose
  --   called from loader
  --   Update translation only.
  -- History
  --   07-19-99  A Lal  Created
  -- Arguments
  -- period_type,user_period_type, description, owner and force_edits

  PROCEDURE TRANSLATE_ROW(
                 x_period_type 		in varchar2,
                 x_user_period_type 	in varchar2,
                 x_description     	in varchar2,
                 x_owner          	in varchar2,
                 x_force_edits          in varchar2 );

  --
  -- Procedure
  --  load_row
  -- Purpose
  --   called from loader
  --   update existing data, insert new data
  -- History
  --   07-19-99  A Lal  Created
  -- Arguments
  -- all the columns of the table GL_PERIOD_TYPES
  -- Example
  --   gl_period_types_pkg.load_row(....;

 PROCEDURE LOAD_ROW(
                x_period_type			in varchar2,
                x_number_per_fiscal_year 	in number,
                x_year_type_in_name     	in varchar2,
                x_user_period_type      	in varchar2,
                x_description          		in varchar2,
                x_attribute1          		in varchar2,
                x_attribute2         		in varchar2,
                x_attribute3       		in varchar2,
                x_attribute4       		in varchar2,
                x_attribute5      		in varchar2,
                x_context      			in varchar2,
                x_owner       			in varchar2,
                x_force_edits 			in varchar2 default 'N'
               );
  --
  -- Procedure
  --  update_row
  -- Purpose
  --   called from loader
  --   update existing data
  -- History
  --   07-19-99  A Lal  Created
  -- Arguments
  -- all the columns of the table GL_PERIOD_TYPES
  -- Example
  --   gl_period_types_pkg.update_row(....;

PROCEDURE UPDATE_ROW(
    x_row_id                        in varchar2,
    x_period_type       	    in varchar2,
    x_number_per_fiscal_year        in number,
    x_year_type_in_name             in varchar2,
    x_user_period_type              in varchar2,
    x_description                   in varchar2,
    x_attribute1                    in varchar2,
    x_attribute2                    in varchar2,
    x_attribute3                    in varchar2,
    x_attribute4                    in varchar2,
    x_attribute5                    in varchar2,
    x_context                       in varchar2,
    x_last_update_date  	    in date,
    x_last_updated_by   	    in number,
    x_last_update_login 	    in number ,
    x_creation_date     	    in date
  );

  --
  -- Procedure
  --  insert_row
  -- Purpose
  --   called from loader
  -- History
  --   07-19-99  A Lal  Created
  -- Arguments
  -- all the columns of the table GL_PERIOD_TYPES
  -- Example
  --   gl_period_types_pkg.insert_row(....;

PROCEDURE INSERT_ROW(
    x_row_id                     in out NOCOPY varchar2,
    x_period_type                   in varchar2,
    x_number_per_fiscal_year        in number,
    x_year_type_in_name             in varchar2,
    x_user_period_type              in varchar2,
    x_description                   in varchar2,
    x_attribute1                    in varchar2,
    x_attribute2                    in varchar2,
    x_attribute3                    in varchar2,
    x_attribute4                    in varchar2,
    x_attribute5                    in varchar2,
    x_context                       in varchar2,
    x_last_update_date              in date,
    x_last_updated_by               in number,
    x_last_update_login             in number ,
    x_creation_date                 in date,
    x_created_by  	            in number
  );

 --
  -- Procedure
  --  checkUpdate
  -- Purpose
  --   called from iSpeed calendar api
  -- History
  --   11-01-00  A Lal  Created
  -- Arguments
  -- all the columns of the table GL_PERIOD_TYPES
  -- Example
  --   gl_period_types_pkg.checkUpdate(....;

 procedure checkUpdate(
             mReturnValue          OUT NOCOPY VARCHAR2
            ,mPeriodType           IN VARCHAR2
            ,mNumberPerFiscalYear  IN VARCHAR2
            ,mYearTypeInName       IN VARCHAR2
          ) ;


END gl_period_types_pkg;

 

/
