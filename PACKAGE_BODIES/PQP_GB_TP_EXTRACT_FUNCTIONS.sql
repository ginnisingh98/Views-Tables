--------------------------------------------------------
--  DDL for Package Body PQP_GB_TP_EXTRACT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_TP_EXTRACT_FUNCTIONS" AS
-- /* $Header: pqgbtpxf.pkb 120.1 2006/02/06 05:49:38 bsamuel noship $ */
--
--
--  GET_CURRENT_EXTRACT_PERSON
--
--    Returns the ext_rslt_id for the current extract process
--    if one is running, else returns -1
--
  FUNCTION get_current_extract_person
    (p_assignment_id NUMBER  -- context
    )
  RETURN NUMBER
  IS
    l_person_id  NUMBER;
  BEGIN
    SELECT person_id
    INTO   l_person_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = p_assignment_id
      AND  ROWNUM < 2;
    RETURN l_person_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;
--
--  GET_CURRENT_EXTRACT_RESULT
--
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
--
--
  FUNCTION get_current_extract_result
    RETURN NUMBER
  IS
     e_extract_process_not_running EXCEPTION;
     PRAGMA EXCEPTION_INIT(e_extract_process_not_running,-8002);
     l_ext_rslt_id  NUMBER;
  --
  BEGIN
  --
--    SELECT ben_ext_rslt_s.CURRVAL
--    INTO   l_ext_rslt_id
--    FROM   DUAL;

    l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;

    RETURN l_ext_rslt_id;
  --
  EXCEPTION
    WHEN e_extract_process_not_running THEN
      RETURN -1;
  END;
--
--    RAISE_EXTRACT_WARNING
--
--    "Smart" warning function.
--    When called from the Rule of a extract detail data element
--    it logs a warning in the ben_ext_rslt_err table against
--    the person being processed (or as specified by context of
--    assignment id ). It prefixes all warning messages with a
--    string "Warning raised in data element "||element_name
--    This allows the same Rule to be called from different data
--    elements.
--
--    usage example.
--
--    RAISE_EXTRACT_WARNING("No initials were found.")
--
--    RRTURNCODE  MEANING
--    -1          Cannot raise warning against a header/trailer
--                record. System Extract does not allow it.
--
--    -2          No current extract process was found.
--
--    -3          No person was found.A Warning in System Extract
--                is always raised against a person.
--
  FUNCTION raise_extract_warning
    (p_assignment_id     IN     NUMBER -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER
  IS
     l_ext_rslt_id   NUMBER;
     l_person_id     NUMBER;
     l_error_text    VARCHAR2(2000);
     l_return_value  NUMBER:= 0;
  BEGIN
  --
    IF p_assignment_id <> -1 THEN
    --
      l_ext_rslt_id:= get_current_extract_result;

      IF l_ext_rslt_id <> -1 THEN
      --

--        l_error_text:= 'Warning raised in data element ' || p_error_text;
--
-- Commented by VTAKRU Nov 16th this due to 2114438 as this
-- BEN pkg code is checked under BEN patch instead of PER
--
-- Re-introduced for Jan 2002 release as all products are being released
-- together as a family pack and minimum pre-req for Jan release will be
-- the October mini pack.
--
-- Modified for type 2

        If p_error_number is null Then

          l_error_text:= 'Warning raised in data element '||
                           ben_ext_fmt.g_elmt_name||'. '||
                         p_error_text;
        --if no message token is defined then egt the message from
        --ben_ext_fmt.
        Elsif p_token1 is null Then

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;
          l_error_text :=
            ben_ext_fmt.get_error_msg(to_number(substr(p_error_text, 5, 5)),
              p_error_text,ben_ext_fmt.g_elmt_name);

        -- if any token is defined than replace the tokens in the message.
        -- and get the message text from fnd_messages.
        Elsif p_token1 is not null Then

        -- set the Tokens in the warning message and then
        -- get the warning message from fnd_messages.

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;

          fnd_message.set_name('BEN',p_error_text);
          fnd_message.set_token('TOKEN1',p_token1);

          if p_token2 is not null Then
            fnd_message.set_token('TOKEN2',p_token2);
          end if;

          l_error_text := fnd_message.get ;

        End If;


        l_person_id:= NVL(get_current_extract_person(p_assignment_id)
                       ,ben_ext_person.g_person_id);

        IF l_person_id IS NOT NULL THEN
        --
          ben_ext_util.write_err
            (p_err_num           => p_error_number
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'W'
            ,p_person_id         => l_person_id
            ,p_request_id        => fnd_global.conc_request_id
            ,p_business_group_id => fnd_global.per_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );
          l_return_value:= 0;  /* All Well ! */
        --
        ELSE
        --
          l_return_value:= -3; /* Person not found  */
        --
        END IF;
      --
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;
    --
    ELSE
    --
      l_return_value := -1; /* Cannot raise warnings against header/trailers */
    --
    END IF;
  --
  RETURN l_return_value;
  END raise_extract_warning;
--
  FUNCTION raise_extract_error
    (p_business_group_id IN     NUMBER -- context
    ,p_assignment_id     IN     NUMBER -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_fatal_flag        IN     VARCHAR2  DEFAULT 'Y' -- for existing pkgs
    ) RETURN NUMBER
  IS
     l_ext_rslt_id   NUMBER;
     l_person_id     NUMBER;
     l_error_text    VARCHAR2(2000);
     l_error_message VARCHAR2(2000);
     l_return_value  NUMBER:= 0;
  BEGIN
  --
    IF p_business_group_id is not null THEN
    --
      l_ext_rslt_id:= get_current_extract_result;
      IF l_ext_rslt_id <> -1 THEN
      --

        If p_error_number is null Then

          l_error_text:= 'Error raised in data element '||
                          NVL(ben_ext_person.g_elmt_name,ben_ext_fmt.g_elmt_name)||'. '||
                         p_error_text;


	Elsif p_token1 is null Then

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;
          l_error_text :=
            ben_ext_fmt.get_error_msg(to_number(substr(p_error_text, 5, 5)),
              p_error_text,ben_ext_fmt.g_elmt_name);

        -- if any token is defined than replace the tokens in the message.
        -- and get the message text from fnd_messages.
        Elsif p_token1 is not null Then

        -- set the Tokens in the warning message and then
        -- get the warning message from fnd_messages.

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;

          fnd_message.set_name('BEN',p_error_text);
          fnd_message.set_token('TOKEN1',p_token1);

          l_error_text := fnd_message.get ;


        End If; -- End if of error number is null check ...

        IF NVL(p_fatal_flag, 'Y') = 'Y' THEN

          ben_ext_util.write_err
            (p_err_num           => p_error_number
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'F'
            ,p_person_id         => null
            ,p_request_id        => fnd_global.conc_request_id
            ,p_business_group_id => p_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );

          commit;

          raise ben_ext_thread.g_job_failure_error;
          l_return_value:= 0;  /* All Well ! */
        ELSIF p_fatal_flag = 'N' THEN

        l_person_id:= NVL(get_current_extract_person(p_assignment_id)
                       ,ben_ext_person.g_person_id);

          ben_ext_util.write_err
            (p_err_num           => p_error_number
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'E' -- Error
            ,p_person_id         => l_person_id
            ,p_request_id        => fnd_global.conc_request_id
            ,p_business_group_id => p_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );
          l_return_value := 0 ;
        END IF; -- End if of p_fatal_flag is Y check ...
      --
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;
    --
    ELSE
    --
      l_return_value := -1; /* Cannot raise warnings against header/trailers */
    --
    END IF;
  --
  RETURN l_return_value;
  END raise_extract_error;

--
END pqp_gb_tp_extract_functions;

/
