--------------------------------------------------------
--  DDL for Package Body FND_REQUEST_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_REQUEST_COPY" as
/* $Header: AFRSCPRB.pls 115.1 99/07/16 23:26:37 porting sh $ */

procedure request_args(
  req_id 			in  number,
  attribute1  in out varchar2, attribute2  in out varchar2,
  attribute3  in out varchar2, attribute4  in out varchar2,
  attribute5  in out varchar2, attribute6  in out varchar2,
  attribute7  in out varchar2, attribute8  in out varchar2,
  attribute9  in out varchar2, attribute10 in out varchar2,
  attribute11 in out varchar2, attribute12 in out varchar2,
  attribute13 in out varchar2, attribute14 in out varchar2,
  attribute15 in out varchar2, attribute16 in out varchar2,
  attribute17 in out varchar2, attribute18 in out varchar2,
  attribute19 in out varchar2, attribute20 in out varchar2,
  attribute21 in out varchar2, attribute22 in out varchar2,
  attribute23 in out varchar2, attribute24 in out varchar2,
  attribute25 in out varchar2, attribute26 in out varchar2,
  attribute27 in out varchar2, attribute28 in out varchar2,
  attribute29 in out varchar2, attribute30 in out varchar2,
  attribute31 in out varchar2, attribute32 in out varchar2,
  attribute33 in out varchar2, attribute34 in out varchar2,
  attribute35 in out varchar2, attribute36 in out varchar2,
  attribute37 in out varchar2, attribute38 in out varchar2,
  attribute39 in out varchar2, attribute40 in out varchar2,
  attribute41 in out varchar2, attribute42 in out varchar2,
  attribute43 in out varchar2, attribute44 in out varchar2,
  attribute45 in out varchar2, attribute46 in out varchar2,
  attribute47 in out varchar2, attribute48 in out varchar2,
  attribute49 in out varchar2, attribute50 in out varchar2,
  attribute51 in out varchar2, attribute52 in out varchar2,
  attribute53 in out varchar2, attribute54 in out varchar2,
  attribute55 in out varchar2, attribute56 in out varchar2,
  attribute57 in out varchar2, attribute58 in out varchar2,
  attribute59 in out varchar2, attribute60 in out varchar2,
  attribute61 in out varchar2, attribute62 in out varchar2,
  attribute63 in out varchar2, attribute64 in out varchar2,
  attribute65 in out varchar2, attribute66 in out varchar2,
  attribute67 in out varchar2, attribute68 in out varchar2,
  attribute69 in out varchar2, attribute70 in out varchar2,
  attribute71 in out varchar2, attribute72 in out varchar2,
  attribute73 in out varchar2, attribute74 in out varchar2,
  attribute75 in out varchar2, attribute76 in out varchar2,
  attribute77 in out varchar2, attribute78 in out varchar2,
  attribute79 in out varchar2, attribute80 in out varchar2,
  attribute81 in out varchar2, attribute82 in out varchar2,
  attribute83 in out varchar2, attribute84 in out varchar2,
  attribute85 in out varchar2, attribute86 in out varchar2,
  attribute87 in out varchar2, attribute88 in out varchar2,
  attribute89 in out varchar2, attribute90 in out varchar2,
  attribute91 in out varchar2, attribute92 in out varchar2,
  attribute93 in out varchar2, attribute94 in out varchar2,
  attribute95 in out varchar2, attribute96 in out varchar2,
  attribute97 in out varchar2, attribute98 in out varchar2,
  attribute99 in out varchar2, attribute100 in out varchar2) is

  type Arg_tab_type is table of varchar2(240) index by binary_integer;
  arg_tab arg_tab_type;
  attribute_order varchar2(100) := null;
  number_of_arguments number;
  i number;
  srs_flag varchar2(1);
  program_application_id number;
  concurrent_program_name varchar2(30);
begin
  select
    p.srs_flag, p.concurrent_program_name, r.program_application_id,
    r.argument1, r.argument2, r.argument3, r.argument4,
    r.argument5, r.argument6, r.argument7, r.argument8,
    r.argument9, r.argument10, r.argument11, r.argument12,
    r.argument13, r.argument14, r.argument15, r.argument16,
    r.argument17, r.argument18, r.argument19, r.argument20,
    r.argument21, r.argument22, r.argument23, r.argument24,
    r.argument25,  r.number_of_arguments
  into
    srs_flag, concurrent_program_name, program_application_id,
    arg_tab(1), arg_tab(2), arg_tab(3), arg_tab(4),
    arg_tab(5), arg_tab(6), arg_tab(7), arg_tab(8),
    arg_tab(9), arg_tab(10), arg_tab(11), arg_tab(12),
    arg_tab(13), arg_tab(14), arg_tab(15), arg_tab(16),
    arg_tab(17), arg_tab(18), arg_tab(19), arg_tab(20),
    arg_tab(21), arg_tab(22), arg_tab(23), arg_tab(24),
    arg_tab(25), number_of_arguments
  from fnd_concurrent_requests r, fnd_concurrent_programs p
  where req_id = r.request_id
    and r.concurrent_program_id = p.concurrent_program_id
    and r.program_application_id = p.application_id;

  if (number_of_arguments > 25) then
    select
	Argument26, Argument27, Argument28, Argument29, Argument30,
	Argument31, Argument32, Argument33, Argument34, Argument35,
	Argument36, Argument37, Argument38, Argument39, Argument40,
	Argument41, Argument42, Argument43, Argument44, Argument45,
	Argument46, Argument47, Argument48, Argument49, Argument50,
	Argument51, Argument52, Argument53, Argument54, Argument55,
	Argument56, Argument57, Argument58, Argument59, Argument60,
	Argument61, Argument62, Argument63, Argument64, Argument65,
	Argument66, Argument67, Argument68, Argument69, Argument70,
	Argument71, Argument72, Argument73, Argument74, Argument75,
	Argument76, Argument77, Argument78, Argument79, Argument80,
	Argument81, Argument82, Argument83, Argument84, Argument85,
	Argument86, Argument87, Argument88, Argument89, Argument90,
	Argument91, Argument92, Argument93, Argument94, Argument95,
	Argument96, Argument97, Argument98, Argument99, Argument100
      into
	arg_tab(26), arg_tab(27), arg_tab(28), arg_tab(29), arg_tab(30),
	arg_tab(31), arg_tab(32), arg_tab(33), arg_tab(34), arg_tab(35),
	arg_tab(36), arg_tab(37), arg_tab(38), arg_tab(39), arg_tab(40),
	arg_tab(41), arg_tab(42), arg_tab(43), arg_tab(44), arg_tab(45),
	arg_tab(46), arg_tab(47), arg_tab(48), arg_tab(49), arg_tab(50),
	arg_tab(51), arg_tab(52), arg_tab(53), arg_tab(54), arg_tab(55),
	arg_tab(56), arg_tab(57), arg_tab(58), arg_tab(59), arg_tab(60),
	arg_tab(61), arg_tab(62), arg_tab(63), arg_tab(64), arg_tab(65),
	arg_tab(66), arg_tab(67), arg_tab(68), arg_tab(69), arg_tab(70),
	arg_tab(71), arg_tab(72), arg_tab(73), arg_tab(74), arg_tab(75),
	arg_tab(76), arg_tab(77), arg_tab(78), arg_tab(79), arg_tab(80),
	arg_tab(81), arg_tab(82), arg_tab(83), arg_tab(84), arg_tab(85),
	arg_tab(86), arg_tab(87), arg_tab(88), arg_tab(89), arg_tab(90),
	arg_tab(91), arg_tab(92), arg_tab(93), arg_tab(94), arg_tab(95),
	arg_tab(96), arg_tab(97), arg_tab(98), arg_tab(99), arg_tab(100)
      from fnd_conc_request_arguments
     where request_id = req_id;
  end if;

  if (number_of_arguments > 0) then
    attribute_order :=  Fnd_Conc_Request_Pkg.Encode_Attribute_Order(
		  		srs_flag,
				fnd_global.user_id,
				fnd_global.resp_id,
				fnd_global.resp_appl_id,
				program_application_id,
				concurrent_program_name);
  end if;

  arg_tab(0) := chr(0);

  if (attribute_order is null) then
    attribute_order := chr(0);  -- Since instr doesn't like nulls.
  end if;

  attribute1 := arg_tab(instr(attribute_order, chr(1)));
  attribute2 := arg_tab(instr(attribute_order, chr(2)));
  attribute3 := arg_tab(instr(attribute_order, chr(3)));
  attribute4 := arg_tab(instr(attribute_order, chr(4)));
  attribute5 := arg_tab(instr(attribute_order, chr(5)));
  attribute6 := arg_tab(instr(attribute_order, chr(6)));
  attribute7 := arg_tab(instr(attribute_order, chr(7)));
  attribute8 := arg_tab(instr(attribute_order, chr(8)));
  attribute9 := arg_tab(instr(attribute_order, chr(9)));
  attribute10 := arg_tab(instr(attribute_order, chr(10)));
  attribute11 := arg_tab(instr(attribute_order, chr(11)));
  attribute12 := arg_tab(instr(attribute_order, chr(12)));
  attribute13 := arg_tab(instr(attribute_order, chr(13)));
  attribute14 := arg_tab(instr(attribute_order, chr(14)));
  attribute15 := arg_tab(instr(attribute_order, chr(15)));
  attribute16 := arg_tab(instr(attribute_order, chr(16)));
  attribute17 := arg_tab(instr(attribute_order, chr(17)));
  attribute18 := arg_tab(instr(attribute_order, chr(18)));
  attribute19 := arg_tab(instr(attribute_order, chr(19)));
  attribute20 := arg_tab(instr(attribute_order, chr(20)));
  attribute21 := arg_tab(instr(attribute_order, chr(21)));
  attribute22 := arg_tab(instr(attribute_order, chr(22)));
  attribute23 := arg_tab(instr(attribute_order, chr(23)));
  attribute24 := arg_tab(instr(attribute_order, chr(24)));
  attribute25 := arg_tab(instr(attribute_order, chr(25)));
  attribute26 := arg_tab(instr(attribute_order, chr(26)));
  attribute27 := arg_tab(instr(attribute_order, chr(27)));
  attribute28 := arg_tab(instr(attribute_order, chr(28)));
  attribute29 := arg_tab(instr(attribute_order, chr(29)));
  attribute30 := arg_tab(instr(attribute_order, chr(30)));
  attribute31 := arg_tab(instr(attribute_order, chr(31)));
  attribute32 := arg_tab(instr(attribute_order, chr(32)));
  attribute33 := arg_tab(instr(attribute_order, chr(33)));
  attribute34 := arg_tab(instr(attribute_order, chr(34)));
  attribute35 := arg_tab(instr(attribute_order, chr(35)));
  attribute36 := arg_tab(instr(attribute_order, chr(36)));
  attribute37 := arg_tab(instr(attribute_order, chr(37)));
  attribute38 := arg_tab(instr(attribute_order, chr(38)));
  attribute39 := arg_tab(instr(attribute_order, chr(39)));
  attribute40 := arg_tab(instr(attribute_order, chr(40)));
  attribute41 := arg_tab(instr(attribute_order, chr(41)));
  attribute42 := arg_tab(instr(attribute_order, chr(42)));
  attribute43 := arg_tab(instr(attribute_order, chr(43)));
  attribute44 := arg_tab(instr(attribute_order, chr(44)));
  attribute45 := arg_tab(instr(attribute_order, chr(45)));
  attribute46 := arg_tab(instr(attribute_order, chr(46)));
  attribute47 := arg_tab(instr(attribute_order, chr(47)));
  attribute48 := arg_tab(instr(attribute_order, chr(48)));
  attribute49 := arg_tab(instr(attribute_order, chr(49)));
  attribute50 := arg_tab(instr(attribute_order, chr(50)));
  attribute51 := arg_tab(instr(attribute_order, chr(51)));
  attribute52 := arg_tab(instr(attribute_order, chr(52)));
  attribute53 := arg_tab(instr(attribute_order, chr(53)));
  attribute54 := arg_tab(instr(attribute_order, chr(54)));
  attribute55 := arg_tab(instr(attribute_order, chr(55)));
  attribute56 := arg_tab(instr(attribute_order, chr(56)));
  attribute57 := arg_tab(instr(attribute_order, chr(57)));
  attribute58 := arg_tab(instr(attribute_order, chr(58)));
  attribute59 := arg_tab(instr(attribute_order, chr(59)));
  attribute60 := arg_tab(instr(attribute_order, chr(60)));
  attribute61 := arg_tab(instr(attribute_order, chr(61)));
  attribute62 := arg_tab(instr(attribute_order, chr(62)));
  attribute63 := arg_tab(instr(attribute_order, chr(63)));
  attribute64 := arg_tab(instr(attribute_order, chr(64)));
  attribute65 := arg_tab(instr(attribute_order, chr(65)));
  attribute66 := arg_tab(instr(attribute_order, chr(66)));
  attribute67 := arg_tab(instr(attribute_order, chr(67)));
  attribute68 := arg_tab(instr(attribute_order, chr(68)));
  attribute69 := arg_tab(instr(attribute_order, chr(69)));
  attribute70 := arg_tab(instr(attribute_order, chr(70)));
  attribute71 := arg_tab(instr(attribute_order, chr(71)));
  attribute72 := arg_tab(instr(attribute_order, chr(72)));
  attribute73 := arg_tab(instr(attribute_order, chr(73)));
  attribute74 := arg_tab(instr(attribute_order, chr(74)));
  attribute75 := arg_tab(instr(attribute_order, chr(75)));
  attribute76 := arg_tab(instr(attribute_order, chr(76)));
  attribute77 := arg_tab(instr(attribute_order, chr(77)));
  attribute78 := arg_tab(instr(attribute_order, chr(78)));
  attribute79 := arg_tab(instr(attribute_order, chr(79)));
  attribute80 := arg_tab(instr(attribute_order, chr(80)));
  attribute81 := arg_tab(instr(attribute_order, chr(81)));
  attribute82 := arg_tab(instr(attribute_order, chr(82)));
  attribute83 := arg_tab(instr(attribute_order, chr(83)));
  attribute84 := arg_tab(instr(attribute_order, chr(84)));
  attribute85 := arg_tab(instr(attribute_order, chr(85)));
  attribute86 := arg_tab(instr(attribute_order, chr(86)));
  attribute87 := arg_tab(instr(attribute_order, chr(87)));
  attribute88 := arg_tab(instr(attribute_order, chr(88)));
  attribute89 := arg_tab(instr(attribute_order, chr(89)));
  attribute90 := arg_tab(instr(attribute_order, chr(90)));
  attribute91 := arg_tab(instr(attribute_order, chr(91)));
  attribute92 := arg_tab(instr(attribute_order, chr(92)));
  attribute93 := arg_tab(instr(attribute_order, chr(93)));
  attribute94 := arg_tab(instr(attribute_order, chr(94)));
  attribute95 := arg_tab(instr(attribute_order, chr(95)));
  attribute96 := arg_tab(instr(attribute_order, chr(96)));
  attribute97 := arg_tab(instr(attribute_order, chr(97)));
  attribute98 := arg_tab(instr(attribute_order, chr(98)));
  attribute99 := arg_tab(instr(attribute_order, chr(99)));
  attribute100 := arg_tab(instr(attribute_order, chr(100)));
end;


end;

/
