--------------------------------------------------------
--  DDL for Package Body HR_API_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_PARAMS" AS -- Body
/* $Header: hrapiprm.pkb 120.0 2005/05/30 22:41:29 appldev noship $ */
--
-- Global number, which is a count of the number of table entries
-- already gone through.
--
  g_last NUMBER;
  g_overload_ind NUMBER := -1;
--
--
-- Global Tables - the same structure as those returned by dbms_describe.
-- These will be used to store the results from dbms_describe, until all
-- entries have been processed.
--
  g_overload       dbms_describe.number_table;
  g_position       dbms_describe.number_table;
  g_level          dbms_describe.number_table;
  g_argument_name  dbms_describe.varchar2_table;
  g_datatype       dbms_describe.number_table;
  g_default        dbms_describe.number_table;
  g_in_out         dbms_describe.number_table;
  g_length         dbms_describe.number_table;
  g_precision      dbms_describe.number_table;
  g_scale          dbms_describe.number_table;
  g_radix          dbms_describe.number_table;
  g_spare          dbms_describe.number_table;
--
--
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
--                             trying to retrieve.
--
-- Out Parameters:
--   None.
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
  PROCEDURE setup_param_info
    (p_pkg_name  in     varchar2
    ,p_proc_name in     varchar2
    ) IS

-- Error exceptions.

  -- Package does not exist in the database
  --
  Package_Not_Exists  exception;
  Pragma Exception_Init(Package_Not_Exists, -6564);
  --
  -- Procedure does not exist in the package
  --
  Proc_Not_In_Package  exception;
  Pragma Exception_Init(Proc_Not_In_Package, -20001);

  BEGIN
    -- Deal with case when either (or both) of the input values are null
    --
    -- Error message: Package name AND procedure name both required.
    --
    IF (p_pkg_name IS NULL) OR (p_proc_name IS NULL) THEN
      fnd_message.set_name('PER', 'PER_52320_API_DTLS_NOT_SUP');
      fnd_message.raise_error;
    END IF;

    g_last := 1; -- Initialise global parameter counter.

    BEGIN

    -- Call the dbms_describe in order to populate the global tables.
    -- 14-DEC-00: below was changed to use the cover to the dbms_describe
    -- procedure, provided by hr_general.
    hr_general.describe_procedure
      (object_name    => p_pkg_name || '.' || p_proc_name
      ,reserved1      => null
      ,reserved2      => null
      ,overload       => g_overload
      ,position       => g_position
      ,level          => g_level
      ,argument_name  => g_argument_name
      ,datatype       => g_datatype
      ,default_value  => g_default
      ,in_out         => g_in_out
      ,length         => g_length
      ,precision      => g_precision
      ,scale          => g_scale
      ,radix          => g_radix
      ,spare          => g_spare
      );
    EXCEPTION
      -- Deal with any errors that may occur.
      --
      -- When an incorrect Package Name has been given.
      WHEN Package_Not_Exists THEN
        -- Error message: Package PACKAGE does not exist.
        --
        fnd_message.set_name('PER', 'PER_52321_API_PKG_NOT_FOUND');
        fnd_message.raise_error;
      --
      -- When an incorrect Procedure Name has been given.
      WHEN Proc_Not_In_Package THEN
        -- Error message: Procedure PROCEDURE does not exist within
        --                the package PACKAGE.
        --
        fnd_message.set_name('PER', 'PER_52322_PROC_NOT_FOUND');
        fnd_message.raise_error;
    END;

  END setup_param_info;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< handle_overload >----------------------------|
-- ---------------------------------------------------------------------------
--
-- This function, called once, examines the table of parameters already
-- set up, and if the procedure is overloaded, will determine which parameter
-- details to return.  This selection would be the procedure that has
--    - most mandatory IN's
-- or - most OUT parameters
--
-- ---------------------------------------------------------------------------
PROCEDURE handle_overload(p_high_overload OUT NOCOPY number) IS
--
  l_curr_overload number := -1;
  l_high_overload number := -1;
  l_high_mands number;
  l_mand_ins   number;
  l_high_outs  number;
  l_outs       number;
  l_index      number := 1;
--
BEGIN
  LOOP
    IF l_curr_overload <> g_overload(l_index) THEN
       --
       -- If we previously had an overload, check to see if this is
       -- more suitable
       IF l_curr_overload <> -1 THEN
          IF l_high_overload = -1 THEN
             l_high_overload := g_overload(l_index);
          ELSE
             IF l_high_mands < l_mand_ins THEN
                l_high_overload := g_overload(l_index);
             ELSIF ((l_high_mands = l_mand_ins) and
                    (l_high_outs < l_outs)) THEN
                l_high_overload := g_overload(l_index);
             END IF;
          END IF;
       ELSE
          l_mand_ins := 0;
          l_outs := 0;
          l_curr_overload := g_overload(l_index);
       END IF;
    END IF;
    --
    -- Increase the counts
    IF g_in_out(l_index) = 0 THEN
       -- parameter is in, so check for default
       IF (g_default(l_index) = 1) and (g_level(l_index) = 0) THEN
          l_mand_ins := l_mand_ins + 1;
       END IF;
    ELSE
       -- parameter is an in/out or out
       IF g_level(l_index) = 0 THEN
          l_outs := l_outs + 1;
       END IF;
    END IF;
    -- Deal with next parameter
    l_index := l_index + 1;
    --
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_index:=l_index-1;
    IF l_curr_overload <> -1 THEN
       IF l_high_overload = -1 THEN
          l_high_overload := g_overload(l_index);
       ELSE
          IF l_high_mands < l_mand_ins THEN
             l_high_overload := g_overload(l_index);
          ELSIF ((l_high_mands = l_mand_ins) and
                 (l_high_outs < l_outs)) THEN
             l_high_overload := g_overload(l_index);
          END IF;
       END IF;
    ELSE
       l_high_overload := 0;
    END IF;
    p_high_overload := l_high_overload;
end handle_overload;
--
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
--   p_name*   -> The name of the corresponding parameter for the specified
--                procedure.
--   p_in_out* -> A number, depending on whether the parameter is IN, OUT or
--                IN OUT.
--   p_default* -> A number, depending on the datatype of the parameter.
--   p_default* -> A number, depending on whether the parameter has a default
--                 or not.
--   p_overload -> A number, indication whether or not the procedure is
--                 overloaded.
--
--   p_last_param -> A flag, which is true when the last parameter has been
--                   dealt with.
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
PROCEDURE retrieve_param_details
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
  ) IS
  --
  --  Declare Error Exceptions
  --
  -- Package does not exist in the database
  Package_Not_Exists  exception;
  Pragma Exception_Init(Package_Not_Exists, -6564);
  --
  -- Procedure does not exist in the package
  Proc_Not_In_Package  exception;
  Pragma Exception_Init(Proc_Not_In_Package, -20001);
  --
  -- Note a count of how far through the tables we currently are.
  l_count NUMBER;
  --
BEGIN
  --
  -- 1 time only, determine which overload to return
  --
  IF g_overload_ind = -1 THEN
     handle_overload(g_overload_ind);
     l_count := 1;
     WHILE g_overload(l_count) <> g_overload_ind LOOP
        l_count := l_count + 1;
     END LOOP;
     g_last := l_count;
  END IF;
  -- Set the local counter to the number of records dealt with
  --
  l_count := g_last;
  --
  -- Set flag, denoting the last parameter from the tables has been dealt with.
  p_last_param := FALSE;

  BEGIN
  -- If we happen to come across the end of the tables, at any time when we
  -- are trying to copy some parameter details, the exception 'NO_DATA_FOUND'
  -- shall be raised, and appropriately dealt with.
  --
  -- Copy first parameter details.
  IF g_overload(l_count) = g_overload_ind THEN
    p_name1:=g_argument_name(l_count);
    p_in_out1:=g_in_out(l_count);
    p_datatype1 := g_datatype(l_count);
    p_default1 := g_default(l_count);
    p_overload1 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy second parameters details.
    l_count := l_count+1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name2:=g_argument_name(l_count);
    p_in_out2:=g_in_out(l_count);
    p_datatype2 := g_datatype(l_count);
    p_default2:=g_default(l_count);
    p_overload2 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy third parameters details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name3:=g_argument_name(l_count);
    p_in_out3:=g_in_out(l_count);
    p_datatype3 := g_datatype(l_count);
    p_default3:=g_default(l_count);
    p_overload3 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy fourth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name4:=g_argument_name(l_count);
    p_in_out4:=g_in_out(l_count);
    p_datatype4 := g_datatype(l_count);
    p_default4:=g_default(l_count);
    p_overload4 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy fifth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name5:=g_argument_name(l_count);
    p_in_out5:=g_in_out(l_count);
    p_datatype5 := g_datatype(l_count);
    p_default5:=g_default(l_count);
    p_overload5 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy sixth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name6:=g_argument_name(l_count);
    p_in_out6:=g_in_out(l_count);
    p_datatype6 := g_datatype(l_count);
    p_default6:=g_default(l_count);
    p_overload6 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy seventh parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name7:=g_argument_name(l_count);
    p_in_out7:=g_in_out(l_count);
    p_datatype7 := g_datatype(l_count);
    p_default7:=g_default(l_count);
    p_overload7 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy eighth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name8:=g_argument_name(l_count);
    p_in_out8:=g_in_out(l_count);
    p_datatype8 := g_datatype(l_count);
    p_default8:=g_default(l_count);
    p_overload8 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy ninth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name9:=g_argument_name(l_count);
    p_in_out9:=g_in_out(l_count);
    p_datatype9 := g_datatype(l_count);
    p_default9:=g_default(l_count);
    p_overload9 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --
  -- Copy tenth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name10:=g_argument_name(l_count);
    p_in_out10:=g_in_out(l_count);
    p_datatype10 := g_datatype(l_count);
    p_default10:=g_default(l_count);
    g_last := g_last + 10;
    p_overload10 := g_overload(l_count);
  ELSE
    p_last_param := TRUE;
    g_overload_ind := -1;
  END IF;
  --

  --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_last_param:=TRUE;  -- Last parameter HAS been dealt with.
      g_overload_ind := -1;
      g_last := l_count -1;
  END;
END retrieve_param_details;
--
-- Overload version : returns a number type, not boolean, as last parameter.
--
PROCEDURE retrieve_param_details
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
  ,p_last_param  out nocopy number
  ) IS
  --
  --  Declare Error Exceptions
  --
  -- Package does not exist in the database
  Package_Not_Exists  exception;
  Pragma Exception_Init(Package_Not_Exists, -6564);
  --
  -- Procedure does not exist in the package
  Proc_Not_In_Package  exception;
  Pragma Exception_Init(Proc_Not_In_Package, -20001);
  --
  -- Note count of how far through the tables we currently are.
  l_count NUMBER;
  --
BEGIN
  --
  -- 1 time only, determine which overload to return
  --
  IF g_overload_ind = -1 THEN
     handle_overload(g_overload_ind);
     l_count := 1;
     WHILE g_overload(l_count) <> g_overload_ind LOOP
        l_count := l_count + 1;
     END LOOP;
     g_last := l_count;
  END IF;
  -- Set the local counter to the number of records dealt with
  --
  l_count := g_last;
  --
  -- Flag, denoting the last parameter from the tables has been dealt with.
  p_last_param := 0;
  --
  BEGIN
    -- If we happen to come across the end of the tables, at any time when we
    -- are trying to copy some parameter details, the exception 'NO_DATA_FOUND'
    --  shall be raised, and appropriately dealt with.
    --
    -- Copy first parameter details.
  IF g_overload(l_count) = g_overload_ind THEN
    p_name1:=g_argument_name(l_count);
    p_in_out1:=g_in_out(l_count);
    p_datatype1 := g_datatype(l_count);
    p_default1 := g_default(l_count);
    p_overload1 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy second parameters details.
    l_count := l_count+1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name2:=g_argument_name(l_count);
    p_in_out2:=g_in_out(l_count);
    p_datatype2 := g_datatype(l_count);
    p_default2:=g_default(l_count);
    p_overload2 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy third parameters details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name3:=g_argument_name(l_count);
    p_in_out3:=g_in_out(l_count);
    p_datatype3 := g_datatype(l_count);
    p_default3:=g_default(l_count);
    p_overload3 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy fourth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name4:=g_argument_name(l_count);
    p_in_out4:=g_in_out(l_count);
    p_datatype4 := g_datatype(l_count);
    p_default4:=g_default(l_count);
    p_overload4 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy fifth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name5:=g_argument_name(l_count);
    p_in_out5:=g_in_out(l_count);
    p_datatype5 := g_datatype(l_count);
    p_default5:=g_default(l_count);
    p_overload5 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy sixth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name6:=g_argument_name(l_count);
    p_in_out6:=g_in_out(l_count);
    p_datatype6 := g_datatype(l_count);
    p_default6:=g_default(l_count);
    p_overload6 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy seventh parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name7:=g_argument_name(l_count);
    p_in_out7:=g_in_out(l_count);
    p_datatype7 := g_datatype(l_count);
    p_default7:=g_default(l_count);
    p_overload7 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy eighth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name8:=g_argument_name(l_count);
    p_in_out8:=g_in_out(l_count);
    p_datatype8 := g_datatype(l_count);
    p_default8:=g_default(l_count);
    p_overload8 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy ninth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name9:=g_argument_name(l_count);
    p_in_out9:=g_in_out(l_count);
    p_datatype9 := g_datatype(l_count);
    p_default9:=g_default(l_count);
    p_overload9 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
    -- Copy tenth parameter's details.
    l_count := l_count +1;
  IF g_overload(l_count) = g_overload_ind THEN
    p_name10:=g_argument_name(l_count);
    p_in_out10:=g_in_out(l_count);
    p_datatype10 := g_datatype(l_count);
    p_default10:=g_default(l_count);
    g_last := g_last + 10;
    p_overload10 := g_overload(l_count);
  ELSE
    p_last_param := 1;
    g_overload_ind := -1;
  END IF;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_last_param:= 1;  -- Last parameter HAS been dealt with.
      g_overload_ind := -1;
      g_last := l_count -1;
  END;
END retrieve_param_details;
END hr_api_params;

/
