--------------------------------------------------------
--  DDL for Package FF_FORMULA_WEBUI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FORMULA_WEBUI_PKG" AUTHID CURRENT_USER as
/* $Header: fffwebpk.pkh 120.2 2006/05/26 16:07:26 swinton noship $ */
  --
  procedure generate_unique_formula_name(
    p_formula_type_id   in            varchar2,
    p_business_group_id in            number,
    p_legislation_code  in            varchar2,
    p_formula_name         out nocopy varchar2
    );
  --
  procedure validate_formula_name(
    p_formula_name         in out nocopy varchar2,
    p_formula_type_id      in            number,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_effective_start_date in            date,
    p_effective_end_date   in out nocopy date,
    p_return_status           out nocopy varchar2
    );
  --
  procedure insert_formula(
    p_rowid                in out nocopy varchar2,
    p_formula_id           in out nocopy varchar2,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_type_id      in            varchar2,
    p_formula_name         in out nocopy varchar2,
    p_description          in            varchar2,
    p_formula_text         in            long,
    p_sticky_flag          in            varchar2,
    p_last_update_date     in out nocopy date,
    p_return_status           out nocopy varchar2
    );
  --
  procedure update_formula(
    p_rowid                in            varchar2,
    p_formula_id           in            number,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_type_id      in            varchar2,
    p_formula_name         in            varchar2,
    p_description          in            varchar2,
    p_formula_text         in            long,
    p_sticky_flag          in            varchar2,
    p_last_update_date     in out nocopy date,
    p_return_status           out nocopy varchar2
    );
  --
  procedure delete_formula(
    p_rowid                 in            varchar2,
    p_formula_id            in            number,
    p_dt_delete_mode        in            varchar2,
    p_validation_start_date in            date,
    p_validation_end_date   in            date,
    p_effective_date        in            date,
    p_return_status            out nocopy varchar2
    );
  --
  procedure lock_formula(
    p_rowid            in            varchar2,
    p_last_update_date in            date,
    p_return_status       out nocopy varchar2
    );
  --
  procedure compile_formula(
    p_formula_id     in            number,
    p_effective_date in            date,
    p_outcome           out nocopy varchar2,
    p_message           out nocopy varchar2
    );
  --
  procedure compile_formula_autonomously(
    p_formula_type_id      in            number,
    p_effective_start_date in            date,
    p_effective_end_date   in            date,
    p_business_group_id    in            number,
    p_legislation_code     in            varchar2,
    p_formula_text         in            long,
    p_outcome                 out nocopy varchar2,
    p_message                 out nocopy varchar2,
    p_return_status           out nocopy varchar2
    );
  --
  procedure run_formula(
    p_formula_id     in            number,
    p_session_date   in            date,
    p_input_name1    in            varchar2,
    p_input_name2    in            varchar2,
    p_input_name3    in            varchar2,
    p_input_name4    in            varchar2,
    p_input_name5    in            varchar2,
    p_input_name6    in            varchar2,
    p_input_name7    in            varchar2,
    p_input_name8    in            varchar2,
    p_input_name9    in            varchar2,
    p_input_name10   in            varchar2,
    p_input_name11   in            varchar2,
    p_input_name12   in            varchar2,
    p_input_name13   in            varchar2,
    p_input_name14   in            varchar2,
    p_input_name15   in            varchar2,
    p_input_name16   in            varchar2,
    p_input_name17   in            varchar2,
    p_input_name18   in            varchar2,
    p_input_name19   in            varchar2,
    p_input_name20   in            varchar2,
    p_input_name21   in            varchar2,
    p_input_name22   in            varchar2,
    p_input_name23   in            varchar2,
    p_input_name24   in            varchar2,
    p_input_name25   in            varchar2,
    p_input_name26   in            varchar2,
    p_input_name27   in            varchar2,
    p_input_name28   in            varchar2,
    p_input_name29   in            varchar2,
    p_input_name30   in            varchar2,
    p_input_value1   in            varchar2,
    p_input_value2   in            varchar2,
    p_input_value3   in            varchar2,
    p_input_value4   in            varchar2,
    p_input_value5   in            varchar2,
    p_input_value6   in            varchar2,
    p_input_value7   in            varchar2,
    p_input_value8   in            varchar2,
    p_input_value9   in            varchar2,
    p_input_value10  in            varchar2,
    p_input_value11  in            varchar2,
    p_input_value12  in            varchar2,
    p_input_value13  in            varchar2,
    p_input_value14  in            varchar2,
    p_input_value15  in            varchar2,
    p_input_value16  in            varchar2,
    p_input_value17  in            varchar2,
    p_input_value18  in            varchar2,
    p_input_value19  in            varchar2,
    p_input_value20  in            varchar2,
    p_input_value21  in            varchar2,
    p_input_value22  in            varchar2,
    p_input_value23  in            varchar2,
    p_input_value24  in            varchar2,
    p_input_value25  in            varchar2,
    p_input_value26  in            varchar2,
    p_input_value27  in            varchar2,
    p_input_value28  in            varchar2,
    p_input_value29  in            varchar2,
    p_input_value30  in            varchar2,
    p_output_name1   in out nocopy varchar2,
    p_output_name2   in out nocopy varchar2,
    p_output_name3   in out nocopy varchar2,
    p_output_name4   in out nocopy varchar2,
    p_output_name5   in out nocopy varchar2,
    p_output_name6   in out nocopy varchar2,
    p_output_name7   in out nocopy varchar2,
    p_output_name8   in out nocopy varchar2,
    p_output_name9   in out nocopy varchar2,
    p_output_name10  in out nocopy varchar2,
    p_output_name11  in out nocopy varchar2,
    p_output_name12  in out nocopy varchar2,
    p_output_name13  in out nocopy varchar2,
    p_output_name14  in out nocopy varchar2,
    p_output_name15  in out nocopy varchar2,
    p_output_name16  in out nocopy varchar2,
    p_output_name17  in out nocopy varchar2,
    p_output_name18  in out nocopy varchar2,
    p_output_name19  in out nocopy varchar2,
    p_output_name20  in out nocopy varchar2,
    p_output_name21  in out nocopy varchar2,
    p_output_name22  in out nocopy varchar2,
    p_output_name23  in out nocopy varchar2,
    p_output_name24  in out nocopy varchar2,
    p_output_name25  in out nocopy varchar2,
    p_output_name26  in out nocopy varchar2,
    p_output_name27  in out nocopy varchar2,
    p_output_name28  in out nocopy varchar2,
    p_output_name29  in out nocopy varchar2,
    p_output_name30  in out nocopy varchar2,
    p_output_value1     out nocopy varchar2,
    p_output_value2     out nocopy varchar2,
    p_output_value3     out nocopy varchar2,
    p_output_value4     out nocopy varchar2,
    p_output_value5     out nocopy varchar2,
    p_output_value6     out nocopy varchar2,
    p_output_value7     out nocopy varchar2,
    p_output_value8     out nocopy varchar2,
    p_output_value9     out nocopy varchar2,
    p_output_value10    out nocopy varchar2,
    p_output_value11    out nocopy varchar2,
    p_output_value12    out nocopy varchar2,
    p_output_value13    out nocopy varchar2,
    p_output_value14    out nocopy varchar2,
    p_output_value15    out nocopy varchar2,
    p_output_value16    out nocopy varchar2,
    p_output_value17    out nocopy varchar2,
    p_output_value18    out nocopy varchar2,
    p_output_value19    out nocopy varchar2,
    p_output_value20    out nocopy varchar2,
    p_output_value21    out nocopy varchar2,
    p_output_value22    out nocopy varchar2,
    p_output_value23    out nocopy varchar2,
    p_output_value24    out nocopy varchar2,
    p_output_value25    out nocopy varchar2,
    p_output_value26    out nocopy varchar2,
    p_output_value27    out nocopy varchar2,
    p_output_value28    out nocopy varchar2,
    p_output_value29    out nocopy varchar2,
    p_output_value30    out nocopy varchar2,
    p_return_status     out nocopy varchar2
    );
  --
  function isFormulaCompiled(
    p_formula_id in number,
    p_effective_date in date) return varchar2;
  --
  function list_function_params(
    p_function_id in number) return varchar2;
  --
end FF_FORMULA_WEBUI_PKG;

 

/
