--------------------------------------------------------
--  DDL for Package Body HR_DU_DP_PC_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_DP_PC_CONVERSION" AS
/* $Header: perdupc.pkb 115.21 2002/11/28 16:53:55 apholt noship $ */


/*--------------------------- GLOBAL VARIABLES ----------------------------*/

  g_insert_table	INSERT_TABLE_TYPE;
  g_column_headings 	COLUMN_HEADINGS_TABLE;
  g_column_mapped_to 	COLUMN_MAPPED_TO_TABLE;
  g_space 		VARCHAR2(100)	       := hr_du_utility.local_CHR(32);
  g_start_table		STARTING_POINT_TABLE;

/*-------------------------------------------------------------------------*/


-- ------------------------- STORE_COLUMN_MAPPINGS ------------------------
-- Description: This Caches the mapped_to_names and the mapping type
-- into a SQL table to cut down on the number of select statements used
--
--  Input Parameters
--   p_api_module_id    - Identify the api being used
-- ------------------------------------------------------------------------
PROCEDURE STORE_COLUMN_MAPPINGS (p_api_module_id IN NUMBER)
IS

  l_mapped_name		R_MAPPED_TYPE;
  l_counter		NUMBER		:= 1 ;

CURSOR csr_mapped_to_name IS
  SELECT mapping_type, mapped_to_name, column_name
    FROM hr_du_column_mappings
    WHERE api_module_id = p_api_module_id;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.
                                   store_column_mappings', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id ||
                                ')' , 10);

  OPEN csr_mapped_to_name;
  --
    LOOP
      FETCH csr_mapped_to_name INTO l_mapped_name;
      IF csr_mapped_to_name%NOTFOUND THEN
        EXIT;
      ELSE
        g_column_mapped_to(l_counter).r_mapping_type :=
                              l_mapped_name.r_mapping_type;
        g_column_mapped_to(l_counter).r_mapped_to_name :=
                              l_mapped_name.r_mapped_to_name;
        g_column_mapped_to(l_counter).r_mapped_name :=
                              l_mapped_name.r_mapped_name;
        l_counter := l_counter + 1;
      END IF;
    END LOOP;
  --
  CLOSE csr_mapped_to_name;

--
  hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion. ' ||
                                'store_column_mappings', 15);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.
                    store_column_mappings', '(none)', 'R');
    RAISE;
--
END STORE_COLUMN_MAPPINGS;


-- ------------------------- STORE_COLUMN_HEADINGS ------------------------
-- Description: This procedure extracts the column headings for the given
-- line and caches them into a table to save on the number of select
-- statements used in the code.
--
--  Input Parameters
--          p_line_id    - Identifies the UPLOAD_LINE to be used
-- ------------------------------------------------------------------------
PROCEDURE STORE_COLUMN_HEADINGS (p_line_id IN NUMBER)
IS

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.
                                       store_column_headings', 5);
  hr_du_utility.message('PARA', '(p_line_id - ' || p_line_id || ')'
                                , 10);

  hr_du_utility.message('INFO','Select Statement Start ' , 15);

        SELECT
 	  PVAL001, PVAL002, PVAL003,  PVAL004 , PVAL005 , PVAL006,
 	  PVAL007, PVAL008, PVAL009,  PVAL010 , PVAL011, PVAL012,
 	  PVAL013, PVAL014, PVAL015,  PVAL016 , PVAL017,  PVAL018,
 	  PVAL019,  PVAL020,  PVAL021, PVAL022,  PVAL023,  PVAL024,
 	  PVAL025,  PVAL026,  PVAL027, PVAL028,  PVAL029,  PVAL030,
 	  PVAL031,  PVAL032,  PVAL033, PVAL034,  PVAL035,  PVAL036,
 	  PVAL037,  PVAL038,  PVAL039, PVAL040,  PVAL041,  PVAL042,
 	  PVAL043,  PVAL044,  PVAL045, PVAL046,  PVAL047,  PVAL048,
 	  PVAL049,  PVAL050,  PVAL051, PVAL052,  PVAL053,  PVAL054,
 	  PVAL055,  PVAL056,  PVAL057, PVAL058,  PVAL059,  PVAL060,
 	  PVAL061,  PVAL062,  PVAL063, PVAL064,  PVAL065,  PVAL066,
 	  PVAL067,  PVAL068,  PVAL069, PVAL070,  PVAL071,  PVAL072,
 	  PVAL073,  PVAL074,  PVAL075, PVAL076,  PVAL077,  PVAL078,
 	  PVAL079,  PVAL080,  PVAL081, PVAL082,  PVAL083,  PVAL084,
 	  PVAL085,  PVAL086,  PVAL087, PVAL088,  PVAL089,  PVAL090,
 	  PVAL091,  PVAL092,  PVAL093, PVAL094,  PVAL095,  PVAL096,
 	  PVAL097,  PVAL098,  PVAL099, PVAL100, PVAL101, PVAL102,
 	  PVAL103, PVAL104, PVAL105,PVAL106, PVAL107, PVAL108,
 	  PVAL109, PVAL110, PVAL111,PVAL112, PVAL113, PVAL114,
 	  PVAL115, PVAL116, PVAL117,PVAL118, PVAL119, PVAL120,
 	  PVAL121, PVAL122, PVAL123,PVAL124, PVAL125, PVAL126,
 	  PVAL127, PVAL128, PVAL129,PVAL130, PVAL131, PVAL132,
 	  PVAL133, PVAL134, PVAL135,PVAL136, PVAL137, PVAL138,
 	  PVAL139, PVAL140, PVAL141,PVAL142, PVAL143, PVAL144,
 	  PVAL145, PVAL146, PVAL147,PVAL148, PVAL149, PVAL150,
 	  PVAL151, PVAL152, PVAL153,PVAL154, PVAL155, PVAL156,
 	  PVAL157, PVAL158, PVAL159,PVAL160, PVAL161, PVAL162,
 	  PVAL163, PVAL164, PVAL165,PVAL166, PVAL167, PVAL168,
 	  PVAL169, PVAL170, PVAL171,PVAL172, PVAL173, PVAL174,
 	  PVAL175, PVAL176, PVAL177,PVAL178, PVAL179, PVAL180,
 	  PVAL181, PVAL182, PVAL183,PVAL184, PVAL185, PVAL186,
 	  PVAL187, PVAL188, PVAL189,PVAL190, PVAL191, PVAL192,
 	  PVAL193, PVAL194, PVAL195,PVAL196, PVAL197, PVAL198,
 	  PVAL199, PVAL200, PVAL201,PVAL202, PVAL203, PVAL204,
 	  PVAL205, PVAL206, PVAL207,PVAL208, PVAL209, PVAL210,
 	  PVAL211, PVAL212, PVAL213,PVAL214, PVAL215, PVAL216,
  	  PVAL217, PVAL218, PVAL219,PVAL220, PVAL221, PVAL222,
 	  PVAL223, PVAL224, PVAL225,PVAL226, PVAL227, PVAL228,
 	  PVAL229, PVAL230
        INTO
 	  g_column_headings(1), g_column_headings(2), g_column_headings(3),
     	  g_column_headings(4), g_column_headings(5), g_column_headings(6),
 	  g_column_headings(7), g_column_headings(8), g_column_headings(9),
 	  g_column_headings(10), g_column_headings(11), g_column_headings(12),
 	  g_column_headings(13), g_column_headings(14), g_column_headings(15),
 	  g_column_headings(16), g_column_headings(17), g_column_headings(18),
 	  g_column_headings(19), g_column_headings(20), g_column_headings(21),
 	  g_column_headings(22), g_column_headings(23), g_column_headings(24),
 	  g_column_headings(25), g_column_headings(26), g_column_headings(27),
 	  g_column_headings(28), g_column_headings(29), g_column_headings(30),
 	  g_column_headings(31), g_column_headings(32), g_column_headings(33),
 	  g_column_headings(34), g_column_headings(35), g_column_headings(36),
 	  g_column_headings(37), g_column_headings(38), g_column_headings(39),
 	  g_column_headings(40), g_column_headings(41), g_column_headings(42),
 	  g_column_headings(43), g_column_headings(44), g_column_headings(45),
 	  g_column_headings(46), g_column_headings(47), g_column_headings(48),
 	  g_column_headings(49), g_column_headings(50), g_column_headings(51),
 	  g_column_headings(52), g_column_headings(53), g_column_headings(54),
 	  g_column_headings(55), g_column_headings(56), g_column_headings(57),
 	  g_column_headings(58), g_column_headings(59), g_column_headings(60),
 	  g_column_headings(61), g_column_headings(62), g_column_headings(63),
 	  g_column_headings(64), g_column_headings(65), g_column_headings(66),
 	  g_column_headings(67), g_column_headings(68), g_column_headings(69),
 	  g_column_headings(70), g_column_headings(71), g_column_headings(72),
 	  g_column_headings(73), g_column_headings(74), g_column_headings(75),
 	  g_column_headings(76), g_column_headings(77), g_column_headings(78),
 	  g_column_headings(79), g_column_headings(80), g_column_headings(81),
 	  g_column_headings(82), g_column_headings(83), g_column_headings(84),
 	  g_column_headings(85), g_column_headings(86), g_column_headings(87),
 	  g_column_headings(88), g_column_headings(89), g_column_headings(90),
 	  g_column_headings(91), g_column_headings(92), g_column_headings(93),
 	  g_column_headings(94), g_column_headings(95), g_column_headings(96),
 	  g_column_headings(97), g_column_headings(98), g_column_headings(99),
 	  g_column_headings(100),g_column_headings(101),g_column_headings(102),
 	  g_column_headings(103),g_column_headings(104),g_column_headings(105),
 	  g_column_headings(106),g_column_headings(107),g_column_headings(108),
 	  g_column_headings(109),g_column_headings(110),g_column_headings(111),
 	  g_column_headings(112),g_column_headings(113),g_column_headings(114),
 	  g_column_headings(115),g_column_headings(116),g_column_headings(117),
 	  g_column_headings(118),g_column_headings(119),g_column_headings(120),
 	  g_column_headings(121),g_column_headings(122),g_column_headings(123),
 	  g_column_headings(124),g_column_headings(125),g_column_headings(126),
 	  g_column_headings(127),g_column_headings(128),g_column_headings(129),
 	  g_column_headings(130),g_column_headings(131),g_column_headings(132),
 	  g_column_headings(133),g_column_headings(134),g_column_headings(135),
 	  g_column_headings(136),g_column_headings(137),g_column_headings(138),
 	  g_column_headings(139),g_column_headings(140),g_column_headings(141),
 	  g_column_headings(142),g_column_headings(143),g_column_headings(144),
 	  g_column_headings(145),g_column_headings(146),g_column_headings(147),
 	  g_column_headings(148),g_column_headings(149),g_column_headings(150),
 	  g_column_headings(151),g_column_headings(152),g_column_headings(153),
 	  g_column_headings(154),g_column_headings(155),g_column_headings(156),
 	  g_column_headings(157),g_column_headings(158),g_column_headings(159),
 	  g_column_headings(160),g_column_headings(161),g_column_headings(162),
 	  g_column_headings(163),g_column_headings(164),g_column_headings(165),
 	  g_column_headings(166),g_column_headings(167),g_column_headings(168),
 	  g_column_headings(169),g_column_headings(170),g_column_headings(171),
 	  g_column_headings(172),g_column_headings(173),g_column_headings(174),
 	  g_column_headings(175),g_column_headings(176),g_column_headings(177),
 	  g_column_headings(178),g_column_headings(179),g_column_headings(180),
 	  g_column_headings(181),g_column_headings(182),g_column_headings(183),
 	  g_column_headings(184),g_column_headings(185),g_column_headings(186),
 	  g_column_headings(187),g_column_headings(188),g_column_headings(189),
 	  g_column_headings(190),g_column_headings(191),g_column_headings(192),
 	  g_column_headings(193),g_column_headings(194),g_column_headings(195),
 	  g_column_headings(196),g_column_headings(197),g_column_headings(198),
 	  g_column_headings(199),g_column_headings(200),g_column_headings(201),
 	  g_column_headings(202),g_column_headings(203),g_column_headings(204),
 	  g_column_headings(205),g_column_headings(206),g_column_headings(207),
 	  g_column_headings(208),g_column_headings(209),g_column_headings(210),
 	  g_column_headings(211),g_column_headings(212),g_column_headings(213),
 	  g_column_headings(214),g_column_headings(215),g_column_headings(216),
 	  g_column_headings(217),g_column_headings(218),g_column_headings(219),
 	  g_column_headings(220),g_column_headings(221),g_column_headings(222),
 	  g_column_headings(223),g_column_headings(224),g_column_headings(225),
 	  g_column_headings(226),g_column_headings(227),g_column_headings(228),
 	  g_column_headings(229),g_column_headings(230)
    FROM HR_DU_UPLOAD_LINES
    WHERE UPLOAD_LINE_ID = p_line_id;

  hr_du_utility.message('INFO','Select Statement Ends ' , 20);

--
  hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion.' ||
                                   ' store_column_headings', 25);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.
                                             store_column_headings',
                       '(none)', 'R');
    RAISE;
--
END STORE_COLUMN_HEADINGS;


-- ------------------------- VERIFY_API_ATTACHED ---------------------------
-- Description: This Procedure simply checks that the referencing columns
-- with in the HR_DU_UPLOAD_LINES have thier appropriate file attached. i.e.
-- in the person api an error would be raised if they had an address
-- and the address flat file as not present.
--
--  Input Parameters
--        p_mapped_name    - This is the name that your looking for when
--                           running the cursor and comparing to mapped_to_name
--
--   p_upload_header_id    - Identifies the upload_header in the upload
--
--      p_api_module_id    - Identifies the API modules from th others
-- ------------------------------------------------------------------------
PROCEDURE VERIFY_API_ATTACHED (p_mapped_name IN VARCHAR2,
                               p_upload_header_id IN NUMBER,
                               p_api_module_id IN NUMBER)
IS

  l_parent_api_module_id	NUMBER;
  l_descriptor_value		VARCHAR2(2000);
  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);

CURSOR csr_api_id IS
  SELECT parent_api_module_id
  FROM   hr_du_column_mappings
  WHERE  api_module_id = p_api_module_id
  AND    mapped_to_name = p_mapped_name;

CURSOR csr_api_file IS
  SELECT des.descriptor
  FROM   hr_api_modules       api,
         hr_du_descriptors    des,
         hr_du_upload_headers head
  WHERE  api.api_module_id = l_parent_api_module_id
  AND    head.upload_header_id = p_upload_header_id
  AND    head.upload_id = des.upload_id
  AND    upper(api.module_name) = upper(des.descriptor);


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.
                                              verify_api_attached', 5);
  hr_du_utility.message('PARA', '(p_mapped_name - ' || p_mapped_name ||
		')(p_api_module_id - ' || p_api_module_id ||
 		')(p_upload_header_id - ' || p_upload_header_id ||')'
                , 10);
--
  OPEN csr_api_id;
  --
    FETCH csr_api_id INTO l_parent_api_module_id;
    IF csr_api_id%NOTFOUND THEN
      l_fatal_error_message := 'Unable to retrieve the parent_api_module_id'
			        || ' for referencing column ' ||
                                p_mapped_name;
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_api_id;

  OPEN csr_api_file;
  --
    FETCH csr_api_file INTO l_descriptor_value;
    IF csr_api_file%NOTFOUND THEN
      l_fatal_error_message := 'API file is not attached to handle the ' ||
                               'referencing column ' || p_mapped_name;
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_api_file;

--
  hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion.' ||
                                  ' verify_api_attached', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.verify_api_attached'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.verify_api_attached',
                       '(none)', 'R');
    RAISE;
--
END VERIFY_API_ATTACHED;


-- --------------------------- REMOVE_SPACES --------------------------------
-- Description: Leading and Trailing spaces (if they exist) are removed
-- from the varchar2 that is passed in P_WORD. A new varchar with no spaces
-- is then returned along side a boolean stating if it had spaces or not.
--
--  Output Parameters
--        p_word     - This is the varchar passed in to see
--
--        p_spaces   - the delimiter to be used
--
-- ------------------------------------------------------------------------
PROCEDURE REMOVE_SPACES (p_word IN OUT NOCOPY VARCHAR2, p_spaces OUT NOCOPY BOOLEAN)
IS

  l_word_length		NUMBER;
  l_temp_word		VARCHAR2(200);
  l_exit_1		BOOLEAN		:= FALSE;
  l_exit_2		BOOLEAN		:= FALSE;
  l_exit_3		BOOLEAN		:= FALSE;
  l_new_word		VARCHAR2(2000);

BEGIN

  --hr_du_utility.message('ROUT',
  --                    'entry:hr_du_dp_pc_conversion.remove_spaces', 5);
  --hr_du_utility.message('PARA',
  --        '(p_word - ' || p_word || ')' , 10);

  p_spaces := FALSE;
  l_word_length	:= LENGTHB(p_word);

  IF l_word_length IS NULL THEN
    l_word_length := 0;
  END IF;

  --hr_du_utility.message('INFO', 'l_word_length - ' || l_word_length, 99);

  IF l_word_length = 1 AND p_word = g_space THEN
    p_word   := NULL;
    l_exit_1 := TRUE;
  ELSE
    l_new_word := p_word;
    FOR i IN 1..l_word_length LOOP
    --
      l_temp_word := SUBSTRB(p_word, i, 1);
      IF l_temp_word <> g_space THEN
        EXIT;
      ELSE
        l_new_word := SUBSTRB(p_word, i + 1);
        l_exit_2 := TRUE;
      END IF;
    --
    END LOOP;
  END IF;

  IF l_exit_1 = FALSE THEN
    p_word := l_new_word;
    FOR j IN REVERSE 1..l_word_length LOOP
    --
      l_temp_word := SUBSTRB(p_word, j, 1);
      IF l_temp_word <> g_space THEN
        EXIT;
      ELSE
        l_new_word := SUBSTRB(p_word, 1, j - 1 );
        l_exit_3 := TRUE;
      END IF;
    --
    END LOOP;
  END IF;

  IF (l_exit_1 = TRUE) OR (l_exit_2 = TRUE) OR (l_exit_3 = TRUE) THEN
      p_spaces := TRUE;
  END IF;

  p_word := l_new_word;

--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.remove_spaces',
                       '(none)', 'R');
    RAISE;
--
END REMOVE_SPACES;


-- ------------------------- CP_REFERENCING_COLUMNS -----------------------
-- Description: Builds up the strings R_STRING_APIS, R_api_PVALS and
-- R_GENERIC_PVAL in the PL/SQL table. Loops around the column headings
-- for each api and checks them against the cursor constraints, if they
-- meet the requirements then they are placed into the strings.
--
--  Input Parameters
--
--        p_array_pos  - the array position in the PL/SQL table that is
--			 currently being used.
--
-- ------------------------------------------------------------------------
PROCEDURE CP_REFERENCING_COLUMNS(p_array_pos IN NUMBER)
IS

  l_string_apis			VARCHAR2(100);
  l_api_PVALS			VARCHAR2(300);
  l_generic_pval		VARCHAR2(30);
  l_current_pval		VARCHAR2(10);
  l_inner_pval  		VARCHAR2(10);
  l_pval_field			VARCHAR2(50);
  l_inner_field			VARCHAR2(50);
  l_parent_api_module_id	NUMBER;
  l_parent_table		VARCHAR2(35);
  l_length			NUMBER;
  l_string_length		NUMBER;

--Checks the column name to see if it has the properties of holding the
--calling api_modules id (parent's id) in that column.

CURSOR csr_parent_api_module_id IS
  SELECT parent_api_module_id
  FROM hr_du_column_mappings
  WHERE mapping_type = 'D'
  AND parent_api_module_id IS NOT null
  AND column_name = l_pval_field;

--Check to see if the column heading has the properties of a generic
--column. Due to some api modules having two columns specifing both a column
--to store the api module id and the line id.

CURSOR csr_parent_table_column IS
  SELECT parent_table
  FROM hr_du_column_mappings
  WHERE mapping_type = 'D'
  AND parent_table is not null
  AND column_name = l_pval_field;

BEGIN
--
  hr_du_utility.message('ROUT',
                       'entry:hr_du_dp_pc_conversion.cp_referencing_columns',
                       5);
  hr_du_utility.message('PARA', '(p_array_pos - ' || p_array_pos || ')'
                       , 10);
--
  l_string_apis := null;
  l_api_PVALS := null;
  l_generic_pval := null;

  --loops around all the column headings within the upload_line
  FOR i IN 1..230 LOOP
  --
    l_current_pval := LPAD(i,3,'0');
    l_current_pval := 'PVAL' || l_current_pval;
    --fetch the heading stored within the specified upload line
    l_pval_field   := g_column_headings(i);

    OPEN csr_parent_api_module_id;
    --
      FETCH csr_parent_api_module_id INTO l_parent_api_module_id;
      IF csr_parent_api_module_id%NOTFOUND THEN
      --no match on normal case so trying generic case
        OPEN csr_parent_table_column;
        --
          FETCH csr_parent_table_column INTO l_parent_table;
          IF csr_parent_table_column%FOUND THEN
            --loop through the column headings again to search for the
            --position in the line of where the api module id will be stored
            hr_du_utility.message('INFO', l_parent_table, 15);
            FOR j IN 1..230 LOOP
            --
              l_inner_pval := LPAD(j,3,'0');
    	      l_inner_pval := 'PVAL' || l_inner_pval;

              l_inner_field   := g_column_headings(j);

              hr_du_utility.message('INFO', l_inner_field, 20);

	      IF l_parent_table = l_inner_field THEN
              --found the exact position in the line where the api id
              --from the calling table will be stored (l_inner_pval).
	      --
                --storing a null in l_string_apis will signal later on
                --that a generic column has been found
                l_string_apis := l_string_apis || null || ',';
                l_api_PVALS := l_api_PVALS || l_current_pval || ',';
 	        l_generic_pval := l_generic_pval || l_inner_pval || ',';
                EXIT;
	      --
              END IF;
            --
            END LOOP;
          END IF;
        --
        CLOSE csr_parent_table_column;
      --
      ELSE
      --
        hr_du_utility.message('INFO', l_parent_api_module_id , 25);
        l_string_apis := l_string_apis || l_parent_api_module_id || ',';
        l_api_PVALS := l_api_PVALS || l_current_pval || ',';
      --
      END IF;
     --
    CLOSE csr_parent_api_module_id;
  END LOOP;

  --The commas are left in at this section for this causes problems
  --later on in the function PROCESS_LINE where 'null,' which is a check
  --with the ',' removed would be 'null' for the line.
  g_insert_table(p_array_pos).r_string_apis	:= l_string_apis;
  g_insert_table(p_array_pos).r_api_PVALS		:= l_api_PVALS;
  g_insert_table(p_array_pos).r_generic_pval	:= l_generic_pval;

  hr_du_utility.message('INFO', 'l_string_apis : '  || l_string_apis , 30);
  hr_du_utility.message('INFO', 'l_api_PVALS : '    || l_api_PVALS , 35);
  hr_du_utility.message('INFO', 'l_generic_pval : ' || l_generic_pval , 40);

--
  hr_du_utility.message('ROUT',
                'exit:hr_du_dp_pc_conversion.cp_referencing_columns', 45);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
          'hr_du_dp_pc_conversion.cp_referencing_columns', '(none)', 'R');
    RAISE;
--
END CP_REFERENCING_COLUMNS;



-- ----------------------- API_MODULE_ID_TO_TABLE_ID ----------------------
-- Description: Works through the column R_REF_COL_APIS in the PL/SQL
-- table changing the string of the actual api module id's from the
-- HR_API_MODULES table, to a string of the PL/SQL row id's. Which in turn
-- relate to the same API.
-- ------------------------------------------------------------------------
PROCEDURE API_MODULE_ID_TO_TABLE_ID IS

  l_size		NUMBER;
  l_number_references   NUMBER;
  l_reference_pval	VARCHAR2(200);
  l_new_string 		VARCHAR2(300)		:= null;
  l_length 		NUMBER;
  l_string_length	NUMBER;

BEGIN
--
  hr_du_utility.message('ROUT',
               'entry:hr_du_dp_pc_conversion.API_MODULE_id_to_table_id', 5);
--


  --find out the size of the PL/SQL table
  l_size := g_insert_table.count;
  --Loop through the rows in the table to find the one associated with the
  --parent_API_MODULE_id
  FOR i IN 1..l_size LOOP
    IF g_insert_table(i).r_ref_Col_apis IS NOT NULL THEN
      --The next step is to see if there are any referencing columns
      --associated with the api (in R_REF_COL_APIS)
      l_new_string := null;

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                                    g_insert_table(i).r_ref_Col_apis);

      l_number_references :=
            hr_du_di_insert.WORDS_ON_LINE(g_insert_table(i).r_ref_Col_apis);

      hr_du_utility.message('INFO', g_insert_table(i).r_ref_Col_apis , 10);

      --loop around for each reference trying to match its api id with the
      --table id
      FOR j IN 1..l_number_references LOOP
        l_reference_pval := null;

        hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                                    g_insert_table(i).r_ref_Col_apis);

        l_reference_pval := hr_du_di_insert.Return_Word(
                            g_insert_table(i).r_ref_Col_apis, j);

        hr_du_utility.message('INFO', l_reference_pval , 15);

        --create a string with the corresponding PL/SQL table id's
        FOR k IN 1..l_size LOOP
          IF l_reference_pval = g_insert_table(k).r_api_id THEN
            l_new_string := l_new_string || k || ',';
            EXIT;
          END IF;
	END LOOP;
      END LOOP;
      l_length := LENGTHB(',');
      l_string_length :=  LENGTHB(l_new_string);
      l_new_string := SUBSTRB(l_new_string,1, (l_string_length - l_length ));
      hr_du_utility.message('INFO', 'l_new_string : ' || l_new_string , 20);

      --replace the old R_REF_COL_APIS with the new_string
      g_insert_table(i).r_ref_Col_apis := l_new_string;
    END IF;
  END LOOP;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_dp_pc_conversion.
                                   API_MODULE_id_to_table_id', 25);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
        'hr_du_dp_pc_conversion.API_MODULE_id_to_table_id', '(none)', 'R');
    RAISE;
--
END API_MODULE_ID_TO_TABLE_ID;


-- --------------------- RETURN_PARENT_API_MODULE_ID ----------------------
-- Description: Returns the parent_api_module_id from HR_DU_COLUMN_MAPPINGS
-- where the p_reference_string matches an entry in HR_DU_COLUMN_MAPPINGS
-- field mapped_to_name.
--
--  Input Parameters
--        p_api_module_id     - Identifies a specific api in the
--                              HR_API_MODULES
--
--        p_reference_string  - String which holds the value to be compared
--                              to the column mapped_to_name within the
--                              HR_DU_COLUMN_MAPPINGS table
--  Output Parameters
--
--    l_parent_api_module_id  - Parent_api_module_id from the
--			        HR_DU_COLUMN_MAPPINGS table if match found
--
-- ------------------------------------------------------------------------
FUNCTION RETURN_PARENT_API_MODULE_ID (p_api_module_id  IN NUMBER,
                           p_reference_string IN VARCHAR2) RETURN NUMBER
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_parent_api_module_id 	NUMBER;

CURSOR csr_parent_id IS
  SELECT parent_api_module_id
    FROM hr_du_column_mappings
    WHERE api_module_id = p_api_module_id
    AND mapped_to_name = p_reference_string;


BEGIN
--
  hr_du_utility.message('ROUT',
                  'entry:hr_du_dp_pc_conversion.return_parent_api_module_id', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id  ||
 		')(p_reference_string - ' || p_reference_string || ')' , 10);
--
  OPEN csr_parent_id;
  --
    FETCH csr_parent_id INTO l_parent_api_module_id;
    IF csr_parent_id%NOTFOUND THEN
      l_fatal_error_message := 'No PARENT_API_MODULE_ID found with the ' ||
		   ' api module id and the mapped_to_name provided ' ||
                   '( p_api_module_id : ' || p_api_module_id ||
                   ' p_reference_string : ' || p_reference_string || ' )';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_parent_id;

--
  hr_du_utility.message('ROUT',
           'exit:hr_du_dp_pc_conversion.return_parent_api_module_id', 15);
  hr_du_utility.message('PARA', '(l_parent_api_module_id - ' ||
            l_parent_api_module_id || ')' , 20);
--
  RETURN l_parent_api_module_id;

EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
            'hr_du_dp_pc_conversion.return_parent_api_module_id',
            l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
        'hr_du_dp_pc_conversion.return_parent_api_module_id', '(none)', 'R');
    RAISE;
--
END RETURN_PARENT_API_MODULE_ID;


-- ------------------------- RETURN_FIELD_VALUE ----------------------------
-- Description: Dynamic SQL statement contained in a Function. Simply
-- performs the following :-
--
-- SELECT   p_field_name
-- FROM     p_table
-- WHERE    p_field_pk = p_record_id;
--
--  Input Parameters
--
--        p_table        - The table name of where the info is held.
--
--        p_record_id    - The specific record identifier within the table.
--
--        p_field_pk     - Column name where p_record_id will be contained.
--
--        p_field_name   - Column value to be extracted.
--
--  Output Parameters
--
--        l_field_value  - The value contained within that field.
-- ------------------------------------------------------------------------
FUNCTION RETURN_FIELD_VALUE (p_table IN VARCHAR2, p_record_id IN NUMBER,
                       p_field_pk IN VARCHAR2, p_field_name IN VARCHAR2)
                       RETURN VARCHAR2
IS
  l_dyn_sql		VARCHAR2(2000);
  l_field_value 	VARCHAR2(2000);
  l_cursor_handle	INT;
  l_rows_processed	INT;

BEGIN
--
  hr_du_utility.message('ROUT',
                   'entry:hr_du_dp_pc_conversion.return_field_value', 5);
  hr_du_utility.message('PARA', '(p_table - ' || p_table ||
			')(p_record_id - ' || p_record_id ||
			')(p_field_pk - ' || p_field_pk ||
			')(p_field_name - ' || p_field_name || ')'
                        , 10);
--

  l_dyn_sql := 'SELECT ' || p_field_name ||' FROM ' || p_table ||
               ' WHERE ' || p_field_pk || ' = ' || p_record_id;

  hr_du_utility.message('INFO', l_dyn_sql , 15);

  hr_du_utility.dynamic_sql_str(l_dyn_sql, l_field_value, 2000);

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_dp_pc_conversion.return_field_value', 20);
  hr_du_utility.message('PARA', '(l_field_value - ' || l_field_value || ')',
                         25);
--

  RETURN l_field_value;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.return_field_value',
                       '(none)', 'R');
    RAISE;
--
END RETURN_FIELD_VALUE;



-- ------------------------- MAX_ID_VALUE --------------------------------
-- Description: Returns the maximum value stored with in the specified
-- column of an HR_DU_UPLOAD_LINES (p_id_pval).
--
--  Input Parameters
--
--        p_upload_line_id - Allows the select statement to be confined
--                           to the one upload line
--
--  Output Parameters
--
--     l_max_number  - The maximumn value within the column
--
-- ------------------------------------------------------------------------
FUNCTION MAX_ID_VALUE (p_upload_line_id IN NUMBER)
                             RETURN NUMBER
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_max_number			NUMBER;

  CURSOR csr_max_id IS
   SELECT MAX(to_number(PVAL001))
   FROM hr_du_upload_lines
   WHERE UPLOAD_HEADER_ID IN (SELECT upload_header_id
     			      FROM hr_du_upload_lines
                              WHERE upload_line_id = p_upload_line_id)
    AND LINE_TYPE = 'D';

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_dp_pc_conversion.max_id_value', 5);
  hr_du_utility.message('PARA', '(p_upload_line_id - ' || p_upload_line_id ||
                        ')' ,10);
--

--
  OPEN csr_max_id;
  --
    FETCH csr_max_id INTO l_max_number;
    IF csr_max_id%NOTFOUND THEN
      l_fatal_error_message := 'Trying to retrieve the max ID';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_max_id;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_dp_pc_conversion.max_id_value', 20);
  hr_du_utility.message('PARA', '(l_max_number - ' || l_max_number || ')'
                        , 25);
--

  RETURN l_max_number;

EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
            'hr_du_dp_pc_conversion.max_id_value',
            l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.max_id_value',
                       '(none)', 'R');
    RAISE;
--
END MAX_ID_VALUE;


-- ----------------------- GENERAL_REFERENCING_COLUMN ----------------------
-- Description: Checks to see whether the column name passed is a
-- referencing or a datapump column, depending on the variables passed
--
--  Input Parameters
--
--        p_pval_field        - The name of which column the information
--                              should be in.
--
--        p_api_module_id     - API Module id relating to HR_API_MODULES
--
--        p_mapping_type      - The output target i.e. 'D' (datapump) or
--                              'R' (referencing)
--
--  Output Parameters
--
--         l_mapped_name      - The name of the field MAPPED_TO_NAME in
--                              HR_DU_COLUMN_MAPPINGS if a match is found.
-- ------------------------------------------------------------------------
FUNCTION GENERAL_REFERENCING_COLUMN(p_pval_field IN VARCHAR2,
                         p_api_module_id IN NUMBER,
                         p_mapping_type IN VARCHAR2)
                         RETURN VARCHAR2
IS

  l_mapped_name		VARCHAR2(30);

CURSOR csr_ref_col IS
  SELECT mapped_to_name
    FROM hr_du_column_mappings
    WHERE api_module_id = p_api_module_id
    AND   mapping_type = p_mapping_type
    AND   upper(column_name) = upper(p_pval_field);

BEGIN
--
  hr_du_utility.message('ROUT',
            'entry:hr_du_dp_pc_conversion.general_referencing_column', 5);
  hr_du_utility.message('PARA', '(p_pval_field- ' || p_pval_field ||
			')(p_api_module_id - ' || p_api_module_id ||
			')(p_mapping_type - ' || p_mapping_type || ')'
                        , 10);
--
  OPEN csr_ref_col;
  --
    FETCH csr_ref_col INTO l_mapped_name;
    IF csr_ref_col%NOTFOUND THEN
      l_mapped_name := null;
    END IF;
  --
  CLOSE csr_ref_col;
--
  hr_du_utility.message('ROUT',
            'exit:hr_du_dp_pc_conversion.general_referencing_column', 15);
  hr_du_utility.message('PARA', '(l_mapped_name - ' || l_mapped_name || ')'
                        , 20);
--

  RETURN l_mapped_name;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_dp_pc_conversion.general_referencing_column','(none)', 'R');
    RAISE;
--
END GENERAL_REFERENCING_COLUMN;

-- ----------------------- GENERAL_REFERENCING_COLUMN_2 ---------------------
-- Description: Checks to see whether the column name passed is a
-- referencing or a datapump column, depending on the variables passed
--
--  Input Parameters
--
--        p_pval_field        - The name of which column the information
--                              should be in.
--
--        p_mapping_type      - The output target i.e. 'D' (datapump) or
--                              'R' (referencing)
--
--  Output Parameters
--
--         l_mapped_name      - The name of the field MAPPED_TO_NAME in
--                              HR_DU_COLUMN_MAPPINGS if a match is found.
-- ------------------------------------------------------------------------
FUNCTION GENERAL_REFERENCING_COLUMN_2(p_pval_field IN VARCHAR2,
                         p_mapping_type IN VARCHAR2) RETURN VARCHAR2
IS

  l_counter	NUMBER;
  l_mapped_name VARCHAR2(50)	:= NULL;

BEGIN

  l_counter := g_column_mapped_to.COUNT;
  FOR i IN 1..l_counter LOOP
    IF (g_column_mapped_to(i).r_mapping_type = p_mapping_type) AND
       (upper(g_column_mapped_to(i).r_mapped_name) = upper(p_pval_field)) THEN
      l_mapped_name := g_column_mapped_to(i).r_mapped_to_name;
      EXIT;
    END IF;
  END LOOP;

  RETURN l_mapped_name;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
       'hr_du_dp_pc_conversion.general_referencing_column_2','(none)', 'R');
    RAISE;
--
END GENERAL_REFERENCING_COLUMN_2;



-- ------------------------- INSERT_API_MODULE_IDS -------------------------
-- Description: The R_API_ID column of the PL/SQL table is populated with
-- API Module id's from HR_API_MODULES table. The id's are ordered by
-- PROCESS_ORDER.
--
--  Input Parameters
--
--        p_upload_id   - Identifies the entry in the upload table that the
--                        referencing will be applied to.
--
-- ------------------------------------------------------------------------
PROCEDURE INSERT_API_MODULE_IDS(p_upload_id IN NUMBER)
IS

  CURSOR csr_apis IS
   SELECT api.api_module_id, des2.upload_header_id
  FROM hr_du_descriptors des1,
       hr_du_descriptors des2,
       hr_du_descriptors des3,
       hr_api_modules api
  WHERE des1.upload_id = p_upload_id
    and upper(des1.descriptor) = 'API'
    and des1.descriptor_type = 'D'
    and des1.value IS NOT null
    and upper(des2.descriptor) = 'PROCESS ORDER'
    and des2.descriptor_type = 'D'
    and upper(des3.descriptor) = 'REFERENCING'
    and des3.value = 'PC'
    and des1.upload_header_id = des2.upload_header_id
    and des1.upload_header_id = des3.upload_header_id
    and upper(des1.value) = api.module_name
  ORDER BY des2.value;


--cursor checks to see if there are any files to be processed
--meaning there maybe CP files.
  CURSOR csr_any_files IS
  SELECT value
  FROM hr_du_descriptors
  WHERE upload_id = p_upload_id
    and upper(descriptor) = 'API'
    and descriptor_type = 'D';


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_api_module_id     	NUMBER;
  l_upload_header_id	NUMBER;
  l_counter		NUMBER		:=1;
  l_temp_varchar	VARCHAR2(2000);

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_dp_pc_conversion.insert_api_module_ids', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  --sets the delimiter through out the whole package to be a comma
  hr_du_di_insert.g_current_delimiter   := ',';

  OPEN csr_apis;
  LOOP
  --
    FETCH CSR_APIS INTO l_api_module_id, l_upload_header_id;
    EXIT WHEN CSR_APIS%NOTFOUND;
      g_insert_table(l_counter).r_api_id     		:= l_api_module_id;
      create_insert_string(l_api_module_id, l_upload_header_id, l_counter);
      l_counter := l_counter + 1;
  --
  END LOOP;

  IF l_counter = 1 THEN
    OPEN csr_any_files;
      FETCH CSR_ANY_FILES INTO l_temp_varchar;
      IF CSR_ANY_FILES%NOTFOUND THEN
        l_fatal_error_message := 'No Data found with the upload_id provided ' ||
                                 '( p_upload_id : ' || p_upload_id || ' )';
        RAISE e_fatal_error;
      END IF;
    CLOSE csr_any_files;
  ELSE
    --Call to procedure to begin the first stages of the conversion
    SWITCH_REFERENCING_INITIAL(p_upload_id);
  END IF;

--
  hr_du_utility.message('ROUT',
                  'exit:hr_du_dp_pc_conversion.insert_api_module_ids', 15);
--

EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.insert_api_module_ids'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.insert_api_module_ids'
                       ,'(none)', 'R');
    RAISE;
--
END INSERT_API_MODULE_IDS;


-- ------------------------ CREATE_INSERT_STRING ----------------------------
-- Description: The columns R_NONE_REF_PVAL, R_REF_PVAL,
-- R_ID_CURVAL, R_REF_COL_NAMES and  R_REF_COL_APIS in the PL/SQL table
-- are all populated for each particular api.
--
--  Input Parameters
--
--    p_api_module_id   -  Identifies the API
--
-- p_upload_header_id   -  Identifies the correct upload record
--
--        p_array_pos   -  The position within the global table
--
-- ------------------------------------------------------------------------
PROCEDURE CREATE_INSERT_STRING(p_api_module_id IN NUMBER,
                               p_upload_header_id IN NUMBER,
                               p_array_pos IN NUMBER)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
--holds the PVAL*** of the none refencing columns
  l_pval_string		VARCHAR2(32767)		:= null;
--holds the PVAL*** of the refencing columns
  l_pval_reference	VARCHAR2(32767)		:= null;
--holds the string representation of the column names
  l_reference_string	VARCHAR2(32767)		:= null;
  l_current_pval	VARCHAR2(10);
  l_line_id		NUMBER;
  l_di_line_number 	NUMBER;
  l_pval_field		VARCHAR2(50);
  l_mapped_name 	VARCHAR2(50);
  l_length		NUMBER;
  l_string_length	NUMBER;
  l_api_name		VARCHAR2(20);
  l_id_currval		NUMBER			:= null;
  l_api_module_id	NUMBER;
  l_api_module_id_string	VARCHAR2(200)	:= null;
  l_spaces		BOOLEAN			:= FALSE;
  l_spreadsheet_cell	VARCHAR2(10);

--Returns the upload_line_id from HR_DU_UPLOAD_LINES where the header id,
--and the LINE_TYPE match i.e. the column headers 'C'.
  CURSOR csr_line_id IS
  SELECT  UPLOAD_LINE_ID
    FROM  hr_du_upload_lines
    WHERE upload_header_id =  p_upload_header_id
    AND   LINE_TYPE = 'C';

  CURSOR csr_DI_LINE_NUMBER IS
  SELECT DI_LINE_NUMBER
    FROM  hr_du_upload_lines
    WHERE upload_line_id = l_line_id;

  CURSOR csr_api_file IS
  SELECT des.value
  FROM   hr_api_modules       api,
         hr_du_descriptors    des,
         hr_du_upload_headers head
  WHERE  api.api_module_id = p_api_module_id
  AND    head.upload_header_id = p_upload_header_id
  AND    head.upload_id = des.upload_id
  AND    upper(api.module_name) = upper(des.descriptor);

BEGIN
--
  hr_du_utility.message('ROUT',
                     'entry:hr_du_dp_pc_conversion.create_insert_string', 5);
  hr_du_utility.message('PARA', '(p_api_module_id - ' || p_api_module_id ||
 			')(p_upload_header_id - ' || p_upload_header_id ||
			')(p_array_pos - ' || p_array_pos || ')' ,
                        10);
--
  OPEN csr_line_id;
    FETCH csr_line_id INTO l_line_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := 'No appropriate column title row exists in '||
                              'the HR_DU_UPLOAD_LINES for the api passed';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_line_id;

  --change the status of the PC row column heading to reflect that processing
  --on that line has started.
  UPDATE hr_du_upload_lines
  SET    status = 'S'
  WHERE  upload_line_id = l_line_id;

  COMMIT;

  --CACHE COLUMN HEADINGS
  STORE_COLUMN_HEADINGS(l_line_id);

  --CACHE MAPPED_TO_NAMES
  STORE_COLUMN_MAPPINGS (p_api_module_id);

  --Called to handle all of the data associated with the fields
  --R_STRING_APIS, R_API_PVALS, R_GENERIC_PVAL in the PL/SQL table
  CP_REFERENCING_COLUMNS(p_array_pos);

  l_pval_string := null;
  l_pval_reference := null;

  --loops around all the columns within the upload_line
  FOR i IN 1..230 LOOP
  --
    l_current_pval := LPAD(i,3,'0');
    l_current_pval := 'PVAL' || l_current_pval;
    --returns the value at the specified field
    l_pval_field   := g_column_headings(i);
    --
    REMOVE_SPACES (l_pval_field, l_spaces);
    IF l_spaces = TRUE THEN
      hr_du_utility.message('INFO', 'l_pval_field (with spaces removed) : '
      || l_pval_field , 20);
    END IF;

    --checks to see if the l_pval_field is a ('D') datapump column, if it
    --isn't null will be returned
    l_mapped_name  := general_referencing_column_2(l_pval_field, 'D');
    IF l_mapped_name IS NOT NULL THEN
      --builds up string of PVAL*** for the datapump column headings
      l_pval_string := l_pval_string || l_current_pval || ',';
    ELSE
      --catches all referencing columns ('R')
      l_mapped_name  := general_referencing_column_2(l_pval_field, 'R');
      IF l_mapped_name IS NOT NULL THEN
        VERIFY_API_ATTACHED(l_mapped_name, p_upload_header_id,
                            p_api_module_id);
        l_reference_string := l_reference_string || l_mapped_name || ',';
        l_pval_reference := l_pval_reference || l_current_pval || ',';
        l_api_module_id := return_parent_api_module_id(p_api_module_id,
                            l_mapped_name);
        --amends the api_module id to the string which the current api will
        --reference
	l_api_module_id_string := l_api_module_id_string || l_api_module_id
                             || ',';
        --check to see if the end of the row has been reached null
        --presumes the end of the row

        --this statement looks for ID columns, assumption only one column
      ELSIF l_pval_field = 'ID' THEN
        NULL;
      ELSIF l_pval_field IS NULL THEN
        exit;
      ELSE
        --deals with column names that don't match any data within
        --HR_DU_COLUMN_MAPPINGS
        --the line number of the HR_DU_UPLOAD_LINE relating to the position
        --it was in within the spreadsheet is extracted
        OPEN csr_DI_LINE_NUMBER;
          FETCH csr_DI_LINE_NUMBER INTO l_di_line_number;
        CLOSE csr_DI_LINE_NUMBER;

        --cursor returns the file name to display to the user the file
        --where the error has occured
	OPEN csr_api_file;
          FETCH csr_api_file INTO l_api_name;
  	CLOSE csr_api_file;

        l_spreadsheet_cell := hr_du_utility.Return_Spreadsheet_row(i);
        l_fatal_error_message := 'In ' || l_api_name ||
              ' there is an invalid column name within cell ' ||
              l_spreadsheet_cell || l_di_line_number;
        RAISE e_fatal_error;
      END IF;
    END IF;
  --
  END LOOP;

  --removes the last ',' at the end of the string
  l_length := LENGTHB(',');
  l_string_length := LENGTHB(l_pval_string);
  l_pval_string := SUBSTRB(l_pval_string,1, (l_string_length - l_length));

  --check to see if any value is within the referencing strings
  l_string_length := LENGTHB(l_pval_reference);
  IF l_string_length > 0 THEN
    l_pval_reference := SUBSTRB(l_pval_reference,1,
                               (l_string_length - l_length));
    l_string_length := LENGTHB(l_reference_string);
    l_reference_string := SUBSTRB(l_reference_string,1,
                                 (l_string_length - l_length));
    l_string_length := LENGTHB(l_api_module_id_string);
    l_api_module_id_string := SUBSTRB(l_api_module_id_string,1,
                                 (l_string_length - l_length));
  END IF;

  --works out the maximum value in the ID column of the header
  l_id_currval	 := MAX_ID_VALUE(l_line_id);

  --insert the values into the appropriate table
  g_insert_table(p_array_pos).r_none_ref_PVAL	:= l_pval_string;
  g_insert_table(p_array_pos).r_ref_PVAL	:= l_pval_reference;
  g_insert_table(p_array_pos).r_id_curval 	:= l_id_currval;
  g_insert_table(p_array_pos).r_ref_Col_Names	:= l_reference_string;
  g_insert_table(p_array_pos).r_ref_Col_apis	:= l_api_module_id_string;

  hr_du_utility.message('INFO', l_pval_string, 15);
  hr_du_utility.message('INFO', l_pval_reference, 20);
  hr_du_utility.message('INFO', l_id_currval, 30);
  hr_du_utility.message('INFO', l_reference_string, 35);
  hr_du_utility.message('INFO', l_api_module_id_string, 45);


  --change the status of the PC row column heading to show that
  --I've completed
  UPDATE hr_du_upload_lines
  SET    status = 'C'
  WHERE  upload_line_id = l_line_id;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_dp_pc_conversion.create_insert_string', 50);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.create_insert_string'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.create_insert_string'
                       ,'(none)', 'R');
    RAISE;
--
END CREATE_INSERT_STRING;


-- ------------------------- SWITCH_REFERENCING_INITIAL -------------------
-- Description: This is the first stage of the actual reference change. The
-- procedure selects one line from the highest process_ordered upload_line
-- and passes this to PROCESS_LINE.
--
-- Input Parameters
--
--    p_upload_id      -  Identify the correct HR_DU_UPLOADS
--
-- ------------------------------------------------------------------------
PROCEDURE SWITCH_REFERENCING_INITIAL(p_upload_id IN NUMBER)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_upload_line_id	NUMBER;
  l_upload_header_id	NUMBER;
  l_api_module_id	NUMBER;
  l_row_id		NUMBER;
  l_table_size		NUMBER;
  l_file_name		VARCHAR2(30);
  l_temp_upload_header	NUMBER;
  l_temp_api_module_id	NUMBER;
  l_counter 		NUMBER	:=1;
  l_size		NUMBER	:=0;


  CURSOR csr_starting_point IS
  SELECT  desc1.UPLOAD_HEADER_ID
    FROM  hr_du_descriptors  desc1,
          hr_du_descriptors  desc2,
          hr_du_descriptors  desc3
    WHERE upper(desc1.DESCRIPTOR) = 'STARTING POINT'
    AND   upper(desc1.VALUE) = 'YES'
    AND   desc1.upload_id = p_upload_id
    AND   upper(desc2.DESCRIPTOR) = 'REFERENCING'
    AND   upper(desc2.VALUE) = 'PC'
    AND   upper(desc3.DESCRIPTOR) = 'API'
    AND   upper(desc3.VALUE) IS NOT NULL
    AND   desc2.upload_header_id = desc1.upload_header_id
    AND   desc3.upload_header_id = desc1.upload_header_id;

  CURSOR csr_header_to_api IS
  SELECT  api_module_id
    FROM  hr_du_upload_headers
    WHERE upload_header_id = l_temp_upload_header;


  CURSOR csr_field_value IS
  SELECT  to_number(PVAL001)
    FROM  hr_du_upload_lines
    WHERE upload_line_id = l_upload_line_id;

BEGIN
--
  hr_du_utility.message('ROUT',
             'entry:hr_du_dp_pc_conversion.switch_referencing_initial', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  --call the procedure to convert all api_module id's held within
  --R_REF_COL_APIS into table_id that reference other positions
  --within the PL/SQl table.
  api_module_id_to_table_id;

  l_table_size := g_insert_table.count;

  --this cursor populates g_start_table with all the starting point
  --upload_header_ids
  OPEN csr_starting_point;
  --
    LOOP
      FETCH csr_starting_point INTO l_temp_upload_header;
      IF csr_starting_point%NOTFOUND THEN
        IF l_Counter = 1 THEN
          l_fatal_error_message := 'No Starting point included on any of ' ||
                                   'the PC files';
          RAISE e_fatal_error;
        ELSE
          EXIT;
        END IF;
      ELSE
          g_start_table(l_counter) := l_temp_upload_header;
          l_counter := l_counter + 1;
      END IF;
    END LOOP;

  --
  CLOSE csr_starting_point;
  --
  --the outer loop deals with lines that have not been handled after the first
  --pass of the highest ordered api_modules, meaning those with the starting
  --points. Meaning any line not referenced by will be passed in this way.

  FOR i IN 1..l_counter LOOP
  --
    OPEN csr_header_to_api;
    --
      FETCH csr_header_to_api INTO l_temp_api_module_id;
      IF csr_header_to_api%NOTFOUND THEN
        l_fatal_error_message := 'Unable to match header id to api module id';
        RAISE e_fatal_error;
      ELSE
        l_api_module_id := g_insert_table(i).r_api_id;
        IF (l_size = 0) and (l_api_module_id <> l_temp_api_module_id) THEN
          l_fatal_error_message := 'The highest Process order with a ' ||
             'referencing type of PC is not flagged as a starting point. ' ||
             'Also make sure all processing order IDs are unique.';
          RAISE e_fatal_error;
        ELSE
          l_size := l_size + 1;
          l_api_module_id := l_temp_api_module_id;
          LOOP
            BEGIN
            --
              SELECT line.upload_line_id, line.upload_header_id
              INTO   l_upload_line_id, l_upload_header_id
              FROM   hr_du_upload_lines     line,
                     hr_du_upload_headers   head
              WHERE  head.upload_id = p_upload_id
               AND    head.api_module_id = l_api_module_id
               AND    line.upload_header_id = head.upload_header_id
               AND    line.status = 'NS'
               AND    line.reference_type = 'PC'
               AND    line.line_type = 'D'
               AND    rownum  < 2;		--only gets one row
            EXCEPTION
             WHEN no_data_found THEN
                EXIT;
            --
            END;

            --Statement extracts the ID number for the particular
            --upload_line_id that was passed in.

            OPEN csr_field_value;
            --
              FETCH csr_field_value INTO l_row_id;
              IF csr_field_value%NOTFOUND THEN
                l_fatal_error_message := 'Unable to retrieve PVAL001 value';
                RAISE e_fatal_error;
              END IF;
            --
            CLOSE csr_field_value;

            hr_du_utility.message('INFO','ID value of the upload_line ' ||
                                  l_row_id, 15);
            hr_du_utility.message('INFO','api_module ID associated with ' ||
                                  'the ID value ' || 1, 20);

            --recursive function PROCESS_LINE is initiated on the chosen
            --row_id
            PROCESS_LINE(null, null, l_row_id, i, l_upload_header_id,
                          p_upload_id);
          END LOOP;
          --
        END IF;
      END IF;
    CLOSE csr_header_to_api;
  END LOOP;
  --

  --checks for any lines that haven't been processed
  FOR j IN 1..l_table_size LOOP
    --
    BEGIN
      l_api_module_id := g_insert_table(j).r_api_id;

      l_upload_line_id		:= NULL;
      l_upload_header_id	:= NULL;

      SELECT line.upload_line_id, line.upload_header_id
      INTO   l_upload_line_id, l_upload_header_id
      FROM   hr_du_upload_lines     line,
               hr_du_upload_headers   head
      WHERE  head.upload_id = p_upload_id
        AND    head.api_module_id = l_api_module_id
        AND    line.upload_header_id = head.upload_header_id
        AND    line.status = 'NS'
        AND    line.reference_type = 'PC'
        AND    line.line_type = 'D'
        AND    rownum  < 2;		--only gets one row
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    IF l_upload_line_id IS NOT NULL THEN
      l_file_name := hr_du_rules.RETURN_UPLOAD_HEADER_FILE(l_upload_header_id);
      OPEN csr_field_value;
      --
        FETCH csr_field_value INTO l_row_id;
        IF csr_field_value%NOTFOUND THEN
          l_fatal_error_message := ' ID ' || l_row_id || ' in ' ||
	 		l_file_name || ' has not been referenced.';
          RAISE e_fatal_error;
        END IF;
        --
      CLOSE csr_field_value;
      --
    END IF;
    --
  END LOOP;

--
  hr_du_utility.message('ROUT',
               'exit:hr_du_dp_pc_conversion.switch_referencing_initial', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
        'hr_du_dp_pc_conversion.switch_referencing_initial'
        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
           'hr_du_dp_pc_conversion.switch_referencing_initial','(none)', 'R');
    RAISE;
--
END SWITCH_REFERENCING_INITIAL;


-- ------------------------- PROCESS_LINE -----------------------------------
-- Description: Each line passed here is duplicated and changed accordingly
-- to CP referencing, any dependants on that line are in turn passed into
-- this procedure to be processed.
--
--  Input Parameters
--
--     p_prev_upload_line_id - The name of the previous line ID which called
--                             this function.
--     p_prev_table_number   - The number of the previous array position which
--                             holds all of the relevant data for the
--                             conversion
--     p_target_ID           - The ID line that you are going to be working on
--                             (not the HR_DU_UPLOAD_LINE.id)
--     p_target_api_module   - The number of the current array position
--                             that holds all of the relevant data for the
--                             conversion
--     p_upload_header_id    - maintains a solid link to the
--			       HR_DU_UPLOADS table of the target line, so not
--			       just the ID values are relied on.
--     p_upload_id	     - Link to HR_DU_UPLOADS
-- ------------------------------------------------------------------------
PROCEDURE PROCESS_LINE(p_prev_upload_line_id IN NUMBER, p_prev_table_number
          IN NUMBER, p_target_ID IN NUMBER, p_target_api_module in NUMBER,
          p_upload_header_id IN NUMBER, p_upload_id IN NUMBER) IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  --id of the PC line passed in
  l_upload_line_id		NUMBER;
  l_number_references		NUMBER;
  l_built_up_string1		VARCHAR2(32767);
  l_built_up_string2		VARCHAR2(20);
  l_built_up_string3		VARCHAR2(32767);
  l_date_string 		VARCHAR2(50);
  --newly created CP line id
  l_line_id			NUMBER;
  l_reference_pval		VARCHAR2(50);
  l_cell_value			VARCHAR2(200);
  l_target_api_module		NUMBER;
  l_upload_header_id		NUMBER;
  l_single_api_module		VARCHAR2(10);
  l_single_pval			VARCHAR2(10);
  l_generic_pval		VARCHAR2(10);
  l_found_flag			BOOLEAN		:=FALSE;
  l_spaces			BOOLEAN		:=FALSE;
  l_cursor_handle		INT;
  l_rows_processed		INT;
  l_table_size			NUMBER;
  l_temp_header_id		NUMBER;
  l_original_upload_header_id	NUMBER;


  CURSOR csr_line_id IS
  SELECT UPLOAD_LINE_ID
  FROM   hr_du_upload_lines
  WHERE upload_header_id = p_upload_header_id
   AND  PVAL001 = to_char(p_target_ID)
   AND  REFERENCE_TYPE = 'PC';



BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.process_line',
                                5);
  hr_du_utility.message('PARA', '(p_prev_upload_line_id - ' ||
                   p_prev_upload_line_id ||
                   ')(p_prev_table_number - ' || p_prev_table_number ||
                   ')(p_target_ID  - ' || p_target_ID  ||
                   ')(p_upload_header_id  - ' || p_upload_header_id  ||
	           ')(p_target_api_module  - ' || p_target_api_module  || ')' ,
                   10);
--

  --Finds out if a starting point points to another looks through all headers with a starting point
  IF (p_prev_upload_line_id IS NOT NULL) AND
     (p_prev_table_number IS NOT NULL) THEN
    l_table_size := g_start_table.count;

    FOR i IN 1..l_table_size LOOP
    --
      l_temp_header_id := g_start_table(i);
      IF l_temp_header_id = p_upload_header_id THEN
        l_fatal_error_message := 'Starting point is unable to reference '||
                                 'other starting point';
        RAISE e_fatal_error;
      END IF;
    --
    END LOOP;
  END IF;

  BEGIN

    OPEN csr_line_id;
    --
      FETCH csr_line_id INTO l_upload_line_id;
      IF csr_line_id%NOTFOUND THEN
        l_fatal_error_message := ' Unable to fine ID ' || p_target_ID ||
          ' in API ' || g_insert_table(p_target_api_module).r_api_id ||
          '. Referencing column in other file has this invalid reference';
        RAISE e_fatal_error;
      END IF;
    --
    CLOSE csr_line_id;

  EXCEPTION
    WHEN OTHERS THEN
      l_fatal_error_message := 'Error has occured searching for the ' ||
               'upload_line_id associated with the upload_header_id of ' ||
               p_upload_header_id || ' and ID column number of ' ||
               p_target_ID;
      RAISE e_fatal_error;
  END;

  hr_du_utility.message('INFO', 'l_upload_line_id : ' || l_upload_line_id, 15);

  --change the status of the PC row to show we're processing this
  UPDATE hr_du_upload_lines
  SET    status = 'S'
  WHERE  upload_line_id = l_upload_line_id;

  Select HR_DU_UPLOAD_LINES_S.nextval
  INTO l_line_id
  FROM dual;

  Select ORIGINAL_UPLOAD_HEADER_ID
  INTO l_original_upload_header_id
  FROM hr_du_upload_lines
  WHERE upload_line_id = l_upload_line_id;

  --String being built up simply creates a new UPLOAD_LINE with all of the
  --none referencing columns' data being copied across
  l_built_up_string1 := 'INSERT INTO hr_du_upload_lines( ' ||
 	' UPLOAD_LINE_ID, UPLOAD_HEADER_ID, BATCH_LINE_ID, ' ||
       	' STATUS, REFERENCE_TYPE, LINE_TYPE, LAST_UPDATE_DATE, ' ||
       	' LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE, ' ||
        ' ORIGINAL_UPLOAD_HEADER_ID, PVAL001,' ||
          g_insert_table(p_target_api_module).r_none_ref_PVAL || ' ) SELECT  '
          || l_line_id || ',' ||
     	p_upload_header_id || ',' ||
      	'null,' ||
      	'''S'',' ||
      	'''CP'',' ||
      	'''D'',';
  l_built_up_string2 := ', 1, 1, 1,' ;
  l_built_up_string3 := ' ,' || l_original_upload_header_id || ' ,' ||
              ( g_insert_table(p_target_api_module).r_id_curval + 1) ||
              ',' || g_insert_table(p_target_api_module).r_none_ref_PVAL ||
              ' FROM hr_du_upload_lines ' ||
              ' WHERE upload_line_id = ' || l_upload_line_id;

  --grab the sysdate and formate it to the correct style to be executed later
  SELECT ' to_date(''' || to_char(sysdate, 'YYYY/MM/DD') ||
                   ''' , ''YYYY/MM/DD'' ) '
  INTO l_date_string
  FROM dual;

  --Increment the maximum current value R_ID_CURVAL for the api_module stored
  --in the PL/SQL table
  g_insert_table(p_target_api_module).r_id_curval :=
                 g_insert_table(p_target_api_module).r_id_curval + 1;

  hr_du_utility.message('INFO', l_built_up_string1 || l_date_string ||
            l_built_up_string2 || l_date_string || l_built_up_string3, 20);

  hr_du_utility.dynamic_sql(l_built_up_string1 || l_date_string ||
            l_built_up_string2 || l_date_string || l_built_up_string3);

  --Next step is to see if there are any referencing columns
  --associated with the api_module

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters
                   (g_insert_table(p_target_api_module).r_ref_Col_apis);

  l_number_references :=
  hr_du_di_insert.WORDS_ON_LINE(g_insert_table
                                (p_target_api_module).r_ref_Col_apis);

  --if l_number_references is zero then it won't enter the loop
  FOR i IN 1..l_number_references LOOP
  --
    --Find the appropriate column in the old PC row where the referencing
    --details are held
    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                          g_insert_table(p_target_api_module).r_ref_PVAL);

    l_reference_pval := hr_du_di_insert.Return_Word(
                      g_insert_table(p_target_api_module).r_ref_PVAL, i);

    hr_du_utility.message('INFO', 'l_reference_pval : '
                            || l_reference_pval, 25);

    --identify the target row in the PL/SQL table that holds all of the
    --information on that particular api_module
    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                  g_insert_table(p_target_api_module).r_ref_Col_apis);

    l_target_api_module := hr_du_di_insert.Return_Word(
              g_insert_table(p_target_api_module).r_ref_Col_apis, i);

    hr_du_utility.message('INFO', 'l_target_api_module : '
                            || l_target_api_module, 30);

    --Target the value of the cell with the appropriate PVAL*** supplied
    --by l_reference_pval
    l_cell_value := RETURN_FIELD_VALUE ('HR_DU_UPLOAD_LINES',
 		l_upload_line_id, 'upload_line_id', l_reference_pval);

    --removes leading and trailing spaces from the reference number
    REMOVE_SPACES (l_cell_value, l_spaces);
    IF l_spaces = TRUE THEN
      hr_du_utility.message('INFO', 'l_cell_value (with spaces removed) : '
                                                     || l_cell_value , 20);
    END IF;
    --

    hr_du_utility.message('INFO', 'l_cell_value : ' || l_cell_value, 35);

    IF l_cell_value IS NOT NULL THEN
    --
      --To find out the upload_header_id I extract the upload_id and then
      --search for a header with the appropriate target api_module and the
      --correct upload_id

-- *************************************************************************************************
-- *************************************************************************************************


     l_built_up_string1 := 'SELECT head.upload_header_id '||
         'FROM hr_du_upload_headers head, ' ||
              'hr_du_descriptors des '||
         'WHERE head.upload_id = ' || p_upload_id ||
         ' AND  head.api_module_id = ' ||
         g_insert_table(l_target_api_module).r_api_id ||
         'AND des.upload_header_id = head.upload_header_id ' ||
         'AND des.descriptor = ''API''  ' ||
         'AND des.value IS NOT NULL';

      hr_du_utility.message('INFO', l_built_up_string1, 35);

      hr_du_utility.dynamic_sql_num(l_built_up_string1, l_upload_header_id);

      hr_du_utility.message('INFO',
                    'Entering call to Process Line.' , 40);

      PROCESS_LINE(g_insert_table(p_target_api_module).r_id_curval,
            p_target_api_module, l_cell_value, l_target_api_module,
            l_upload_header_id, p_upload_id);

      hr_du_utility.message('INFO',
                 'Returned from call to Process Line.' || l_cell_value, 45);
    --
    END IF;
  --
  END LOOP;

  --check to see whether I have to add information to the current line
  --to hold details about the calling line
  IF p_prev_upload_line_id IS NOT NULL THEN

    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                       g_insert_table(p_target_api_module).r_string_apis);
    l_number_references := hr_du_di_insert.WORDS_ON_LINE(
                       g_insert_table(p_target_api_module).r_string_apis);

    hr_du_utility.message('INFO', 'r_string_apis : ' ||
                   g_insert_table(p_target_api_module).r_string_apis ,50);
    hr_du_utility.message('INFO', l_number_references ,55);

    --this loop catches all occurrences
    FOR j IN 1..l_number_references LOOP
    --
      --Extracts the first api_module id from R_STRING_APIS
      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                    g_insert_table(p_target_api_module).r_string_apis);
      l_single_api_module := hr_du_di_insert.Return_Word(
                  g_insert_table(p_target_api_module).r_string_apis, j);

      --checks for a match with api_module id's in R_STRING_APIS
      --and the old api_module id from the calling line (p_prev_table_number)
      IF l_single_api_module =
                    g_insert_table(p_prev_table_number).r_api_id THEN
      --
         --Recalls the pval*** in the PL/SQL table so the data can be stored
         --in the correct position in the UPLOAD_LINE
         hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                  g_insert_table(p_target_api_module).R_API_PVALS);
         l_single_pval := hr_du_di_insert.Return_Word(
                g_insert_table(p_target_api_module).R_API_PVALS, j);

         --modifies the line with the extra CP referencing information
         l_built_up_string1 := 'update HR_DU_UPLOAD_LINES SET ' ||
                        l_single_pval || ' = ''' || p_prev_upload_line_id ||
                        ''' WHERE upload_line_id = ' || l_line_id;

         hr_du_utility.message('INFO', l_built_up_string1 ,50);

         hr_du_utility.dynamic_sql(l_built_up_string1);

         --Set to true for api_module id matches has precedence over generic
         --matches. (this is handled in the next loop)
         l_found_flag := TRUE;
         EXIT;
      --
      END IF;
    END LOOP;

    --Searching for generic matches, if you find a null it just takes the
    --first one it comes across
    IF l_found_flag = FALSE THEN
      FOR j IN 1..l_number_references LOOP
      --
        hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                  g_insert_table(p_target_api_module).r_string_apis);
        l_single_api_module := hr_du_di_insert.Return_Word(
                    g_insert_table(p_target_api_module).r_string_apis, j);

        IF l_single_api_module IS NULL THEN
        --
          hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                  g_insert_table(p_target_api_module).R_API_PVALS);
          l_single_pval := hr_du_di_insert.Return_Word(
                  g_insert_table(p_target_api_module).R_API_PVALS, j);

          hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                  g_insert_table(p_target_api_module).r_generic_pval);
          l_generic_pval := hr_du_di_insert.Return_Word(
                  g_insert_table(p_target_api_module).r_generic_pval, j);

          l_built_up_string3 := 'update HR_DU_UPLOAD_LINES SET ' ||
                             l_single_pval || ' = ''' || p_prev_upload_line_id
                             || ''',' || l_generic_pval || ' = ''' ||
                             g_insert_table(p_prev_table_number).r_api_id ||
                             ''' WHERE upload_line_id = ' || l_line_id;

          hr_du_utility.message('INFO', l_built_up_string3 ,55);

          hr_du_utility.dynamic_sql(l_built_up_string3);

          EXIT;
        --
        ELSE
          null;
        END IF;
      --
      END LOOP;
    END IF;
  END IF;

  --change the status of the PC row to show we've completed the process
  UPDATE hr_du_upload_lines
  SET    status = 'C'
  WHERE  upload_line_id = l_upload_line_id;

  --change the status of the CP row to show we've completed the process
  UPDATE hr_du_upload_lines
  SET    status = 'C'
  WHERE  upload_line_id = l_line_id;

  COMMIT;

--
 hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion.process_line', 60);
--

--
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.process_line'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.process_line',
                       '(none)', 'R');
    RAISE;
--
END PROCESS_LINE;


-- ------------------------- VALIDATE -----------------------------------
-- Description: The validation procedure is a pre check and insures that
-- the module is not being run on tables that are already in the CP
-- format.
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE(p_upload_id IN NUMBER) IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_source_reference_type	VARCHAR2(30);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.validate', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  l_source_reference_type := NULL;

--
  hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion.validate', 15);
--

--
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_dp_pc_conversion.validate'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.validate',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE;


-- ------------------------- ROLLBACK -----------------------------------
-- Description: This procedure is called when an error has occured so that
-- the database tables can be cleaned up to restart the processing module
-- again
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE ROLLBACK(p_upload_id IN NUMBER) IS


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_dp_pc_conversion.rollback', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')' , 10);
--


  DELETE FROM HR_DU_UPLOAD_LINES
  WHERE UPLOAD_HEADER_ID IN (SELECT head.upload_header_id
                           FROM hr_du_upload_headers head,
				hr_du_descriptors  des
                           WHERE head.upload_id = p_upload_id
			     AND head.upload_header_id = des.upload_header_id
			     AND upper(des.descriptor) = 'REFERENCING'
 			     AND upper(des.value) = 'PC')
  AND REFERENCE_TYPE = 'CP';
  COMMIT;

  UPDATE hr_du_upload_lines
  SET status = 'NS'
  WHERE UPLOAD_HEADER_ID IN (SELECT upload_header_id
                             FROM hr_du_upload_headers
                             WHERE upload_id = p_upload_id)
  AND status <> 'NS';
  COMMIT;

--
  hr_du_utility.message('ROUT','exit:hr_du_dp_pc_conversion.rollback', 15);
--

--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_dp_pc_conversion.rollback',
                       '(none)', 'R');
    RAISE;
--
END ROLLBACK;

END HR_DU_DP_PC_CONVERSION;

/
