--------------------------------------------------------
--  DDL for Package Body PAY_ZA_ACB_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_ACB_TAPE" as
/* $Header: pyzaacb.pkb 120.1 2006/05/17 03:24:20 nragavar ship $ */
  /* This cursor is used for the retrieval of both */
  /* User and Installation generation numbers      */

  Cursor get_gen_no(p_payroll_action_id number, p_code varchar2) is
                        Select
          nvl(max(acb.gen_number),0) + 1
                        From
                                  pay_za_acb_user_gen_nos       acb
                        Where
                                  acb.user_code  = p_code
                        And acb.payroll_action_id =
                            (
                            Select max(sub.payroll_action_id)
                            From   pay_za_acb_user_gen_nos sub
                            Where  sub.user_code = p_code
                            )
                        And     not exists
                                 (
                                 Select         1
                                 From           pay_za_acb_user_gen_nos sub
                                 Where  sub.payroll_action_id = p_payroll_action_id
                                 And    sub.user_code = p_code
                                 )
                        Union
                        Select
                            acb.gen_number
                        From
                                  pay_za_acb_user_gen_nos       acb
                        Where
                                  acb.user_code  = p_code
                        And acb.payroll_action_id =     p_payroll_action_id;


        Function get_acb_user_gen_num
                        (
                         p_payroll_action_id    in number
                        ,p_user_code            in varchar2
                        )
        return number is

--      l_return_val    number(30);

        Begin

                /* get gen number used on last tape submitted */

      Open get_gen_no(p_payroll_action_id, p_user_code);
      Fetch get_gen_no into user_gen;

      /* Set the gen number = 1 if table contains no entries */

      If  get_gen_no%notfound then
          user_gen := 1;
      End if;

      Close get_gen_no;

      /* Check that gen no does not exceed 9999, if so, reset to 1 */

      If  user_gen > 9999 then
          user_gen := 1;
      End if;

                  /* Insert the new gen number into pay_za_acb_user_gen_nos */

                  Insert into pay_za_acb_user_gen_nos
                        (
                        payroll_action_id
                        ,user_code
                        ,gen_number
                        )
                  Select
                          p_payroll_action_id
                        , p_user_code
                        , user_gen
                  From
                    sys.dual
                  Where
                    not exists
                                (
                                 Select         1
                                 From           pay_za_acb_user_gen_nos sub
                                 Where  sub.payroll_action_id = p_payroll_action_id
                                 And    sub.user_code = p_user_code
                                );

                 return user_gen;

        End get_acb_user_gen_num;

        Function get_acb_inst_gen_num
                (
                 p_payroll_action_id    in      number
                ,p_acb_user_type          in    varchar2
                ,p_acb_inst_code          in    varchar2
                )
        Return Number
        is

--      l_inst_gen              number(10);

        Begin

                If      p_acb_user_type = 'S' then
                        /* Single User: Inst Gen must = User Gen */

        Open get_gen_no(p_payroll_action_id, p_acb_inst_code);
        Fetch get_gen_no into inst_gen;

      /* Set the gen number = 1 if table contains no entries */

        If  get_gen_no%notfound then
            inst_gen := 1;
        End if;

        Close get_gen_no;

      /* Check that gen no does not exceed 9999, if so, reset to 1 */

      If  inst_gen > 9999 then
          inst_gen := 1;
      End if;


      /* Insert new user generation number */

                  Insert into pay_za_acb_user_gen_nos
                        (
                        payroll_action_id
                        ,user_code
                        ,gen_number
                        )
                  Select
                          p_payroll_action_id
                        , p_acb_inst_code
                        , inst_gen
                  From
                    sys.dual
                  Where
                    not exists
                                (
                                 Select         1
                                 From           pay_za_acb_user_gen_nos sub
                                 Where  sub.payroll_action_id = p_payroll_action_id
                                 And    sub.user_code = p_acb_inst_code
                                );
                Else

       /* Bureau User: Inst Gen must > User Gen */

       /* Select the next installation gen no from sequence */

                         Select
                                  pay_za_acb_user_gen_nos_s.nextval into inst_gen
                         From
                                  sys.dual;

                         /* Check that installation gen no > user gen, since the
                            installation gen no may have been reset from 9999 to
                            1 and may then be < user gen no and this cannot be the
                            case with bureau users. */

       If inst_gen <= user_gen then
                            /* add 1 to user gen */
          inst_gen := user_gen + 1;
          /* inst gen cannot be > 9999, it is allowed to have inst gen 1
             when user gen is 9999 */
          If inst_gen > 9999 then
             inst_gen := 1;
          End if;
       End if;


    End if;

                Return (inst_gen);

        End get_acb_inst_gen_num;

End pay_za_acb_tape;

/
