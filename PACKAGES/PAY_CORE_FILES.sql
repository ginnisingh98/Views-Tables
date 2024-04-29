--------------------------------------------------------
--  DDL for Package PAY_CORE_FILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_FILES" AUTHID CURRENT_USER as
/* $Header: pycofile.pkh 120.6.12010000.2 2008/12/26 07:51:39 priupadh ship $ */
--
procedure open_file
                  (p_source_id     in            number,
                   p_source_type   in            varchar2,
                   p_file_location in            varchar2,
                   p_file_type     in            varchar2,
                   p_int_file_name in            varchar2,
                   p_sequence      in            number,
                   p_file_id          out nocopy number
                  );
--
procedure write_to_file
          (p_file_id in number,
           p_text    in varchar2
          );
--
procedure write_to_file_raw
          (p_file_id in number,
           p_text    in raw
          );
--
procedure close_file
               (p_file_id in number);
--
procedure read_from_clob
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          );
--
procedure read_from_clob
          (
           p_clob     in            clob,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          );
--
procedure read_from_clob_raw
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy raw
          );
--
procedure open_temp_file(p_file in out nocopy clob);
--
procedure close_temp_file(p_file in out nocopy clob);
--
-- Added for Bug # 3688801.
procedure form_read_clob
          (
           p_file_id  in            number,
           p_size     in out nocopy number,
           p_position in            number,
           p_text        out nocopy varchar2
          );
--
function return_clob_length
          ( p_file_id  in  number ) return number;
function return_length
          ( p_file_id  in  number )
return number;

procedure write_to_magtape_lob(p_text in varchar);
procedure write_to_magtape_lob(p_data in blob);
--
end pay_core_files;

/
