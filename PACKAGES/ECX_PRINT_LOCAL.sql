--------------------------------------------------------
--  DDL for Package ECX_PRINT_LOCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_PRINT_LOCAL" AUTHID CURRENT_USER as
-- $Header: ECXLXMLS.pls 120.2 2006/05/11 02:08:03 arsriniv ship $

/**
Public Constant Definitions
**/

-- Stores the temporary XML Document in the buffer. Later on it is written to CLOB
-- and parsed using xmlparser.

type		tmpxml_rec is table of varchar2(32767) index by binary_integer;
i_tmpxml	tmpxml_rec;

-- boolean to aid root element printing
first_time_printing	Boolean	:= true;

/**
Formatting tags for XML Document
**/
i_elestarttag	varchar2(1) :='<';
i_eleendtag	varchar2(1) :='>';
i_eleclosetag	varchar2(2) := '</';
i_pistart	varchar2(2) := '<?';
i_piend		varchar2(2) := '?>';
i_commstart	varchar2(4) := '<!--';
i_commend	varchar2(3) := '-->';
i_cdatastarttag varchar2(9) := '<![CDATA[';
i_cdataendtag   varchar2(3) := ']]>';

TYPE	node_stack	is table of pls_integer index by binary_integer;
/**
Define Local Node Stack table
**/
l_node_stack	node_stack;

-- needed for discntinuous elements printng
last_printed            pls_integer := -1;

procedure print_discont_elements
        (
        i_start_pos             IN      pls_integer,
        i_end_pos               IN      pls_integer,
        i_parent_attr_id        IN      pls_integer,
        i_ext_level             IN      pls_integer
        );

procedure xmlPOPALL(
   x_xmldoc OUT NOCOPY  clob);

procedure xmlPUSH
	(
	i       pls_integer
	);
procedure xmlPOP;

procedure element_open
	(
	tag_name	IN	varchar2
	);

procedure element_close;

procedure element_node_open
	(
	tag_name	IN	varchar2,
	value		IN	varchar2,
        clob_value	IN	clob
	);

procedure element_node_close
	(
	tag_name	IN	varchar2
	);

procedure cdata_element_node_open
	(
	tag_name	IN	varchar2,
        value           IN      varchar2,
	clob_value	IN	clob
	);


procedure cdata_element_node_close
	(
	tag_name	IN	varchar2,
        value           IN      varchar2,
	clob_value	IN	clob
	);

procedure get_chunks
        (
          clob_value    IN clob ,
          is_cdata      IN boolean default false
        );

procedure get_chunks
        (
          value    IN Varchar2,
          is_cdata      IN boolean default false

        );

procedure element_node
	(
	tag_name	IN	varchar2,
	value		IN	varchar2
	);

procedure attribute_node
	(
	attribute_name	IN	varchar2,
	attribute_value	IN	varchar2
	);

procedure pi_node
	(
	pi	IN	varchar2,
	attribute_string	in	varchar2 :=NULL
	);

procedure document_node
	(
	root_element    in      varchar2,
	filename        IN      varchar2,
	dtd_url		IN	varchar2
	);

procedure comment_node
	(
	value	IN	varchar2
	);

procedure print_new_level
	(
	i_level		IN	pls_integer,
	i_index		IN	pls_integer
	);

function is_descendant (
        i_parent_id     IN      pls_integer,
        i_element_id    IN      pls_integer
        ) return                boolean;

procedure escape_spec_char (
                           p_value   IN         Varchar2,
                           x_value   OUT NOCOPY Varchar2);

procedure replace_spec_char(
                           p_value   IN         Varchar2,
                           x_value   OUT NOCOPY Varchar2);



end ecx_print_local;

 

/
