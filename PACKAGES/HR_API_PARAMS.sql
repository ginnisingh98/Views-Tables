--------------------------------------------------------
--  DDL for Package HR_API_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_PARAMS" AUTHID CURRENT_USER AS
/* $Header: hrapiprm.pkh 115.1 2002/11/29 12:22:03 apholt ship $ */

-- ---------------------------------------------------------------------------
-- |-------------------------< set_up_param_info >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   Makes the call to the packaged procedure dbms_describe.describe_procedure,
--   which will create tables holding the details of the given procedure from
--   the given package.  This procedure takes this information, and stores it
--   globally, thus making it retrievable by the retrieve_param_details
--   procedure.
--
--   Should the package not exist, or indeed the procedure not exist within the
--   package, then p_exists will be set appropriately.
--
-- Pre-Requisites:
--   Called from the form, prior to attempting to retieve parameter details.
--
-- In Parameters:
--   p_pkg_name   -> The name of the package, in which the procedure exists.
--   p_proc_name  -> The name of the procedure whose parameter details we are
--                   trying to retrieve.
--
-- Out Parameters:
--   None.
--
-- Post Success:
--   The appropriate parameter details will be held in global variables.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure setup_param_info
  (p_pkg_name  in     varchar2
  ,p_proc_name in     varchar2
  );
-- ---------------------------------------------------------------------------
-- |----------------------< retrieve_param_details >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure will return the parameter details of the previously
--   specified procedure, from the previously specified package, having read
--   them from the global tables.
--   The last record will have its flag set appropriately.
--
-- Pre-Requisites:
--   Called from the form, only after the setup_param_info has
--   deposited info within the global tables.
--
-- In Parameters:
--   None
--
-- Out Parameters:
--   p_name*     -> The name of the corresponding parameter for the specified
--                  procedure.
--   p_in_out*   -> A number, depending on whether the parameter is IN, OUT or
--                  IN OUT.
--   p_datatype* -> A number, depending on the datatype of the parameter.
--   p_default*  -> A number, depending on whether the parameter has a default
--                  or not.
--   p_overload* -> A number which indicates whether the procedure is
--                  overloaded or not.
--
--   p_last_param   -> A flag, which is true when the last parameters details
--                     have been dealt with (ie. copied from the global tables)
--
-- Post Success:
--   This procedure will have returned to the form, all possible parameter
--   details for the packaged procedure, as specified in setup_param_info.
--
-- Post Failure:
--   None.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_param_details
  (p_name1     out nocopy varchar2
  ,p_name2     out nocopy varchar2
  ,p_name3     out nocopy varchar2
  ,p_name4     out nocopy varchar2
  ,p_name5     out nocopy varchar2
  ,p_name6     out nocopy varchar2
  ,p_name7     out nocopy varchar2
  ,p_name8     out nocopy varchar2
  ,p_name9     out nocopy varchar2
  ,p_name10    out nocopy varchar2
  ,p_in_out1   out nocopy number
  ,p_in_out2   out nocopy number
  ,p_in_out3   out nocopy number
  ,p_in_out4   out nocopy number
  ,p_in_out5   out nocopy number
  ,p_in_out6   out nocopy number
  ,p_in_out7   out nocopy number
  ,p_in_out8   out nocopy number
  ,p_in_out9   out nocopy number
  ,p_in_out10  out nocopy number
  ,p_datatype1 out nocopy number
  ,p_datatype2 out nocopy number
  ,p_datatype3 out nocopy number
  ,p_datatype4 out nocopy number
  ,p_datatype5 out nocopy number
  ,p_datatype6 out nocopy number
  ,p_datatype7 out nocopy number
  ,p_datatype8 out nocopy number
  ,p_datatype9 out nocopy number
  ,p_datatype10 out nocopy number
  ,p_default1  out nocopy number
  ,p_default2  out nocopy number
  ,p_default3  out nocopy number
  ,p_default4  out nocopy number
  ,p_default5  out nocopy number
  ,p_default6  out nocopy number
  ,p_default7  out nocopy number
  ,p_default8  out nocopy number
  ,p_default9  out nocopy number
  ,p_default10 out nocopy number
  ,p_overload1 out nocopy number
  ,p_overload2 out nocopy number
  ,p_overload3 out nocopy number
  ,p_overload4 out nocopy number
  ,p_overload5 out nocopy number
  ,p_overload6 out nocopy number
  ,p_overload7 out nocopy number
  ,p_overload8 out nocopy number
  ,p_overload9 out nocopy number
  ,p_overload10 out nocopy number
  ,p_last_param  out nocopy boolean
  );
procedure retrieve_param_details
  (p_name1 out nocopy varchar2
  ,p_name2 out nocopy varchar2
  ,p_name3 out nocopy varchar2
  ,p_name4 out nocopy varchar2
  ,p_name5 out nocopy varchar2
  ,p_name6 out nocopy varchar2
  ,p_name7 out nocopy varchar2
  ,p_name8 out nocopy varchar2
  ,p_name9 out nocopy varchar2
  ,p_name10 out nocopy varchar2
  ,p_in_out1 out nocopy number
  ,p_in_out2 out nocopy number
  ,p_in_out3 out nocopy number
  ,p_in_out4 out nocopy number
  ,p_in_out5 out nocopy number
  ,p_in_out6 out nocopy number
  ,p_in_out7 out nocopy number
  ,p_in_out8 out nocopy number
  ,p_in_out9 out nocopy number
  ,p_in_out10 out nocopy number
  ,p_datatype1 out nocopy number
  ,p_datatype2 out nocopy number
  ,p_datatype3 out nocopy number
  ,p_datatype4 out nocopy number
  ,p_datatype5 out nocopy number
  ,p_datatype6 out nocopy number
  ,p_datatype7 out nocopy number
  ,p_datatype8 out nocopy number
  ,p_datatype9 out nocopy number
  ,p_datatype10 out nocopy number
  ,p_default1  out nocopy number
  ,p_default2  out nocopy number
  ,p_default3  out nocopy number
  ,p_default4  out nocopy number
  ,p_default5  out nocopy number
  ,p_default6  out nocopy number
  ,p_default7  out nocopy number
  ,p_default8  out nocopy number
  ,p_default9  out nocopy number
  ,p_default10 out nocopy number
  ,p_overload1 out nocopy number
  ,p_overload2 out nocopy number
  ,p_overload3 out nocopy number
  ,p_overload4 out nocopy number
  ,p_overload5 out nocopy number
  ,p_overload6 out nocopy number
  ,p_overload7 out nocopy number
  ,p_overload8 out nocopy number
  ,p_overload9 out nocopy number
  ,p_overload10 out nocopy number
  ,p_last_param  out nocopy number
  );
end hr_api_params;

 

/
