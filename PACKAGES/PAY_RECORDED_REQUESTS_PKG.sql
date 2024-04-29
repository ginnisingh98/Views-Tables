--------------------------------------------------------
--  DDL for Package PAY_RECORDED_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RECORDED_REQUESTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyrecreq.pkh 115.3 2004/08/05 08:25:26 jford noship $ */

-- ----------------------------------------------------------------------------
-- Name: get_recorded_date
--
-- Description:
--   This procedure returns the date that has been recorded against the request
--   identified by the attributes.
--   If no record exists (no row in table) then a row is created and the default
--   hr_api.g_sot is returned.
--
-- Prerequisites:
--   This is a public procedure which allows code as part of the request to access
--   a single recorded date which may be required for future processing.
--
-- In Parameters:
--   All column values that identify the row explicitly, eg request type and parameter
--   values.  The only out parameter is the current date stored against this row.
--
-- Post Success:
--   The specified row's recorded date will be returned.
--
-- Post Failure:
--   Errors are propogated using usual SQL behaviour.
-- ----------------------------------------------------------------------------

procedure get_recorded_date( p_process in varchar2,
                    p_recorded_date      out nocopy date,
                    p_attribute1         in varchar2 default null,
                    p_attribute2         in varchar2 default null,
                    p_attribute3         in varchar2 default null,
                    p_attribute4         in varchar2 default null,
                    p_attribute5         in varchar2 default null,
                    p_attribute6         in varchar2 default null,
                    p_attribute7         in varchar2 default null,
                    p_attribute8         in varchar2 default null,
                    p_attribute9         in varchar2 default null,
                    p_attribute10        in varchar2 default null,
                    p_attribute11        in varchar2 default null,
                    p_attribute12        in varchar2 default null,
                    p_attribute13        in varchar2 default null,
                    p_attribute14        in varchar2 default null,
                    p_attribute15        in varchar2 default null,
                    p_attribute16        in varchar2 default null,
                    p_attribute17        in varchar2 default null,
                    p_attribute18        in varchar2 default null,
                    p_attribute19        in varchar2 default null,
                    p_attribute20        in varchar2 default null);
-- Variation of above procedure
-- pyccutl.pkb has function to get asg_act_status and this needs
-- to retrieve a date but without any dml because function is called
-- within a view.  This is fine because when a true date needs to be
-- inserted, set_recorded_date can be called at a suitable juncture
--
procedure get_recorded_date_no_ins( p_process in varchar2,
                    p_recorded_date out nocopy date ,
                    p_attribute1         in varchar2 default null ,
                    p_attribute2         in varchar2 default null ,
                    p_attribute3         in varchar2 default null ,
                    p_attribute4         in varchar2 default null ,
                    p_attribute5         in varchar2 default null ,
                    p_attribute6         in varchar2 default null ,
                    p_attribute7         in varchar2 default null ,
                    p_attribute8         in varchar2 default null ,
                    p_attribute9         in varchar2 default null ,
                    p_attribute10        in varchar2 default null ,
                    p_attribute11        in varchar2 default null ,
                    p_attribute12        in varchar2 default null ,
                    p_attribute13        in varchar2 default null ,
                    p_attribute14        in varchar2 default null ,
                    p_attribute15        in varchar2 default null ,
                    p_attribute16        in varchar2 default null ,
                    p_attribute17        in varchar2 default null ,
                    p_attribute18        in varchar2 default null ,
                    p_attribute19        in varchar2 default null ,
                    p_attribute20        in varchar2 default null );

-- ----------------------------------------------------------------------------
-- Name: set_recorded_date
--
-- Description:
--   This procedure sets the recorded date against the request
--   identified by the attributes.
--   If no record exists (no row in table) then a row is created and this new date
--   is used.
--
-- Prerequisites:
--   This is a public procedure which allows code as part of the request to set
--   a single recorded date which may be required for future processing.
--
-- In Parameters:
--   All column values that identify the row explicitly, eg request type and parameter
--   values.  Both the old date held for this row, and the new set date are returned.
--
-- Post Success:
--   The specified row's new recorded dates will be returned.
--
-- Post Failure:
--   Errors are propogated using usual SQL behaviour.
-- ----------------------------------------------------------------------------

procedure set_recorded_date(
                    p_process            in varchar2,
                    p_recorded_date      in date,
                    p_recorded_date_o    out nocopy date,
                    p_attribute1         in varchar2 default null,
                    p_attribute2         in varchar2 default null,
                    p_attribute3         in varchar2 default null,
                    p_attribute4         in varchar2 default null,
                    p_attribute5         in varchar2 default null,
                    p_attribute6         in varchar2 default null,
                    p_attribute7         in varchar2 default null,
                    p_attribute8         in varchar2 default null,
                    p_attribute9         in varchar2 default null,
                    p_attribute10        in varchar2 default null,
                    p_attribute11        in varchar2 default null,
                    p_attribute12        in varchar2 default null,
                    p_attribute13        in varchar2 default null,
                    p_attribute14        in varchar2 default null,
                    p_attribute15        in varchar2 default null,
                    p_attribute16        in varchar2 default null,
                    p_attribute17        in varchar2 default null,
                    p_attribute18        in varchar2 default null,
                    p_attribute19        in varchar2 default null,
                    p_attribute20        in varchar2 default null);

END PAY_RECORDED_REQUESTS_PKG;

 

/
