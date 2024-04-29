--------------------------------------------------------
--  DDL for Package OKE_PRINT_FORM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PRINT_FORM_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPPFMS.pls 115.5 2002/11/19 21:22:00 jxtang ship $ */

--
-- This record type is used to specify an instance of a print form and
-- provide header level data.
--
TYPE PFH_Rec_Type IS RECORD
( --
  -- Form_Header_ID can only be used in Update_Print_Form.  If
  -- populated in Create_Print_Form, the value will be ignored
  --
  Form_Header_ID           oke_k_form_headers.form_header_id%TYPE := NULL
, Print_Form_Code          oke_k_form_headers.print_form_code%TYPE
, Form_Header_Number       oke_k_form_headers.form_header_number%TYPE
, Form_Date                oke_k_form_headers.form_date%TYPE
  --
  -- Either the ID or Number / Type / Intent must be provided for
  -- contract header.  If both are provided, the ID value will be used.
  --
, Contract_Number          oke_k_headers.k_number_disp%TYPE := NULL
, Buy_Or_Sell              okc_k_headers_b.buy_or_sell%TYPE := NULL
, K_Type_Code              oke_k_headers.k_type_code%TYPE := NULL
, Contract_Header_ID       okc_k_headers_b.id%TYPE := NULL
  --
  -- Either the ID or Number maybe provided for contract line.  If
  -- both are provided, the ID value will be used.
  --
, Contract_Line_Number     okc_k_lines_b.line_number%TYPE := NULL
, Contract_Line_ID         okc_k_lines_b.ID%TYPE := NULL
  --
  -- Either the ID or Number maybe provided for deliverable.  If
  -- both are provided, the ID value will be used.
  --
, Deliverable_Number       oke_k_deliverables_b.deliverable_num%TYPE := NULL
, Deliverable_ID           NUMBER         := NULL
  --
  -- Additional Reference columns 1 through 5
  --
, Reference1               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference2               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference3               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference4               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference5               VARCHAR2(240) := FND_API.G_MISS_CHAR
  --
  -- Form Statuses are defined as lookups with lookup_type
  -- OKE_FORM_STATUS.  Either the code or the meaning must be
  -- provided.  If both are provided, the CODE value will be used.
  --
, Status_Name              fnd_lookup_values.meaning%TYPE
, Status_Code              oke_k_form_headers.status_code%TYPE
  --
  -- Header Level Data
  --
, Text01                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text02                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text03                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text04                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text05                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text06                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text07                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text08                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text09                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text10                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text11                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text12                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text13                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text14                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text15                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text16                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text17                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text18                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text19                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text20                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text21                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text22                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text23                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text24                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text25                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text26                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text27                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text28                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text29                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text30                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text31                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text32                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text33                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text34                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text35                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text36                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text37                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text38                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text39                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text40                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text41                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text42                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text43                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text44                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text45                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text46                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text47                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text48                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text49                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text50                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Number01                 NUMBER         := FND_API.G_MISS_NUM
, Number02                 NUMBER         := FND_API.G_MISS_NUM
, Number03                 NUMBER         := FND_API.G_MISS_NUM
, Number04                 NUMBER         := FND_API.G_MISS_NUM
, Number05                 NUMBER         := FND_API.G_MISS_NUM
, Number06                 NUMBER         := FND_API.G_MISS_NUM
, Number07                 NUMBER         := FND_API.G_MISS_NUM
, Number08                 NUMBER         := FND_API.G_MISS_NUM
, Number09                 NUMBER         := FND_API.G_MISS_NUM
, Number10                 NUMBER         := FND_API.G_MISS_NUM
, Number11                 NUMBER         := FND_API.G_MISS_NUM
, Number12                 NUMBER         := FND_API.G_MISS_NUM
, Number13                 NUMBER         := FND_API.G_MISS_NUM
, Number14                 NUMBER         := FND_API.G_MISS_NUM
, Number15                 NUMBER         := FND_API.G_MISS_NUM
, Number16                 NUMBER         := FND_API.G_MISS_NUM
, Number17                 NUMBER         := FND_API.G_MISS_NUM
, Number18                 NUMBER         := FND_API.G_MISS_NUM
, Number19                 NUMBER         := FND_API.G_MISS_NUM
, Number20                 NUMBER         := FND_API.G_MISS_NUM
, Number21                 NUMBER         := FND_API.G_MISS_NUM
, Number22                 NUMBER         := FND_API.G_MISS_NUM
, Number23                 NUMBER         := FND_API.G_MISS_NUM
, Number24                 NUMBER         := FND_API.G_MISS_NUM
, Number25                 NUMBER         := FND_API.G_MISS_NUM
, Number26                 NUMBER         := FND_API.G_MISS_NUM
, Number27                 NUMBER         := FND_API.G_MISS_NUM
, Number28                 NUMBER         := FND_API.G_MISS_NUM
, Number29                 NUMBER         := FND_API.G_MISS_NUM
, Number30                 NUMBER         := FND_API.G_MISS_NUM
, Number31                 NUMBER         := FND_API.G_MISS_NUM
, Number32                 NUMBER         := FND_API.G_MISS_NUM
, Number33                 NUMBER         := FND_API.G_MISS_NUM
, Number34                 NUMBER         := FND_API.G_MISS_NUM
, Number35                 NUMBER         := FND_API.G_MISS_NUM
, Number36                 NUMBER         := FND_API.G_MISS_NUM
, Number37                 NUMBER         := FND_API.G_MISS_NUM
, Number38                 NUMBER         := FND_API.G_MISS_NUM
, Number39                 NUMBER         := FND_API.G_MISS_NUM
, Number40                 NUMBER         := FND_API.G_MISS_NUM
, Number41                 NUMBER         := FND_API.G_MISS_NUM
, Number42                 NUMBER         := FND_API.G_MISS_NUM
, Number43                 NUMBER         := FND_API.G_MISS_NUM
, Number44                 NUMBER         := FND_API.G_MISS_NUM
, Number45                 NUMBER         := FND_API.G_MISS_NUM
, Number46                 NUMBER         := FND_API.G_MISS_NUM
, Number47                 NUMBER         := FND_API.G_MISS_NUM
, Number48                 NUMBER         := FND_API.G_MISS_NUM
, Number49                 NUMBER         := FND_API.G_MISS_NUM
, Number50                 NUMBER         := FND_API.G_MISS_NUM
, Date01                   DATE           := FND_API.G_MISS_DATE
, Date02                   DATE           := FND_API.G_MISS_DATE
, Date03                   DATE           := FND_API.G_MISS_DATE
, Date04                   DATE           := FND_API.G_MISS_DATE
, Date05                   DATE           := FND_API.G_MISS_DATE
, Date06                   DATE           := FND_API.G_MISS_DATE
, Date07                   DATE           := FND_API.G_MISS_DATE
, Date08                   DATE           := FND_API.G_MISS_DATE
, Date09                   DATE           := FND_API.G_MISS_DATE
, Date10                   DATE           := FND_API.G_MISS_DATE
, Date11                   DATE           := FND_API.G_MISS_DATE
, Date12                   DATE           := FND_API.G_MISS_DATE
, Date13                   DATE           := FND_API.G_MISS_DATE
, Date14                   DATE           := FND_API.G_MISS_DATE
, Date15                   DATE           := FND_API.G_MISS_DATE
, Date16                   DATE           := FND_API.G_MISS_DATE
, Date17                   DATE           := FND_API.G_MISS_DATE
, Date18                   DATE           := FND_API.G_MISS_DATE
, Date19                   DATE           := FND_API.G_MISS_DATE
, Date20                   DATE           := FND_API.G_MISS_DATE
, Date21                   DATE           := FND_API.G_MISS_DATE
, Date22                   DATE           := FND_API.G_MISS_DATE
, Date23                   DATE           := FND_API.G_MISS_DATE
, Date24                   DATE           := FND_API.G_MISS_DATE
, Date25                   DATE           := FND_API.G_MISS_DATE
, Date26                   DATE           := FND_API.G_MISS_DATE
, Date27                   DATE           := FND_API.G_MISS_DATE
, Date28                   DATE           := FND_API.G_MISS_DATE
, Date29                   DATE           := FND_API.G_MISS_DATE
, Date30                   DATE           := FND_API.G_MISS_DATE
, Date31                   DATE           := FND_API.G_MISS_DATE
, Date32                   DATE           := FND_API.G_MISS_DATE
, Date33                   DATE           := FND_API.G_MISS_DATE
, Date34                   DATE           := FND_API.G_MISS_DATE
, Date35                   DATE           := FND_API.G_MISS_DATE
, Date36                   DATE           := FND_API.G_MISS_DATE
, Date37                   DATE           := FND_API.G_MISS_DATE
, Date38                   DATE           := FND_API.G_MISS_DATE
, Date39                   DATE           := FND_API.G_MISS_DATE
, Date40                   DATE           := FND_API.G_MISS_DATE
, Date41                   DATE           := FND_API.G_MISS_DATE
, Date42                   DATE           := FND_API.G_MISS_DATE
, Date43                   DATE           := FND_API.G_MISS_DATE
, Date44                   DATE           := FND_API.G_MISS_DATE
, Date45                   DATE           := FND_API.G_MISS_DATE
, Date46                   DATE           := FND_API.G_MISS_DATE
, Date47                   DATE           := FND_API.G_MISS_DATE
, Date48                   DATE           := FND_API.G_MISS_DATE
, Date49                   DATE           := FND_API.G_MISS_DATE
, Date50                   DATE           := FND_API.G_MISS_DATE
);

--
-- This record type is used to specify line level data.  Line level
-- data is optional.
--
TYPE PFL_Rec_Type IS RECORD
( Form_Line_Number         oke_k_form_lines.form_line_number%TYPE
  --
  -- Either the ID or Number / Type / Intent may be provided for
  -- contract header.  If both are provided, the ID value will be used.
  --
, Contract_Number          oke_k_headers.k_number_disp%TYPE := NULL
, Buy_Or_Sell              okc_k_headers_b.buy_or_sell%TYPE := NULL
, K_Type_Code              oke_k_headers.k_type_code%TYPE := NULL
, Contract_Header_ID       okc_k_headers_b.id%TYPE := NULL
  --
  -- Either the ID or Number may be provided for contract line.  If
  -- both are provided, the ID value will be used.
  --
, Contract_Line_Number     okc_k_lines_b.line_number%TYPE := NULL
, Contract_Line_ID         okc_k_lines_b.ID%TYPE := NULL
  --
  -- Either the ID or Number may be provided for deliverable.  If
  -- both are provided, the ID value will be used.
  --
, Deliverable_Number       oke_k_deliverables_b.deliverable_num%TYPE := NULL
, Deliverable_ID           NUMBER         := NULL
  --
  -- Additional Reference columns 1 through 5
  --
, Reference1               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference2               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference3               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference4               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Reference5               VARCHAR2(240) := FND_API.G_MISS_CHAR
, Text01                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text02                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text03                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text04                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text05                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text06                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text07                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text08                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text09                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text10                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text11                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text12                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text13                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text14                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text15                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text16                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text17                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text18                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text19                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text20                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text21                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text22                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text23                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text24                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text25                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text26                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text27                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text28                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text29                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text30                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text31                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text32                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text33                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text34                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text35                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text36                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text37                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text38                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text39                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text40                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text41                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text42                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text43                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text44                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text45                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text46                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text47                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text48                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text49                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Text50                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
, Number01                 NUMBER         := FND_API.G_MISS_NUM
, Number02                 NUMBER         := FND_API.G_MISS_NUM
, Number03                 NUMBER         := FND_API.G_MISS_NUM
, Number04                 NUMBER         := FND_API.G_MISS_NUM
, Number05                 NUMBER         := FND_API.G_MISS_NUM
, Number06                 NUMBER         := FND_API.G_MISS_NUM
, Number07                 NUMBER         := FND_API.G_MISS_NUM
, Number08                 NUMBER         := FND_API.G_MISS_NUM
, Number09                 NUMBER         := FND_API.G_MISS_NUM
, Number10                 NUMBER         := FND_API.G_MISS_NUM
, Number11                 NUMBER         := FND_API.G_MISS_NUM
, Number12                 NUMBER         := FND_API.G_MISS_NUM
, Number13                 NUMBER         := FND_API.G_MISS_NUM
, Number14                 NUMBER         := FND_API.G_MISS_NUM
, Number15                 NUMBER         := FND_API.G_MISS_NUM
, Number16                 NUMBER         := FND_API.G_MISS_NUM
, Number17                 NUMBER         := FND_API.G_MISS_NUM
, Number18                 NUMBER         := FND_API.G_MISS_NUM
, Number19                 NUMBER         := FND_API.G_MISS_NUM
, Number20                 NUMBER         := FND_API.G_MISS_NUM
, Number21                 NUMBER         := FND_API.G_MISS_NUM
, Number22                 NUMBER         := FND_API.G_MISS_NUM
, Number23                 NUMBER         := FND_API.G_MISS_NUM
, Number24                 NUMBER         := FND_API.G_MISS_NUM
, Number25                 NUMBER         := FND_API.G_MISS_NUM
, Number26                 NUMBER         := FND_API.G_MISS_NUM
, Number27                 NUMBER         := FND_API.G_MISS_NUM
, Number28                 NUMBER         := FND_API.G_MISS_NUM
, Number29                 NUMBER         := FND_API.G_MISS_NUM
, Number30                 NUMBER         := FND_API.G_MISS_NUM
, Number31                 NUMBER         := FND_API.G_MISS_NUM
, Number32                 NUMBER         := FND_API.G_MISS_NUM
, Number33                 NUMBER         := FND_API.G_MISS_NUM
, Number34                 NUMBER         := FND_API.G_MISS_NUM
, Number35                 NUMBER         := FND_API.G_MISS_NUM
, Number36                 NUMBER         := FND_API.G_MISS_NUM
, Number37                 NUMBER         := FND_API.G_MISS_NUM
, Number38                 NUMBER         := FND_API.G_MISS_NUM
, Number39                 NUMBER         := FND_API.G_MISS_NUM
, Number40                 NUMBER         := FND_API.G_MISS_NUM
, Number41                 NUMBER         := FND_API.G_MISS_NUM
, Number42                 NUMBER         := FND_API.G_MISS_NUM
, Number43                 NUMBER         := FND_API.G_MISS_NUM
, Number44                 NUMBER         := FND_API.G_MISS_NUM
, Number45                 NUMBER         := FND_API.G_MISS_NUM
, Number46                 NUMBER         := FND_API.G_MISS_NUM
, Number47                 NUMBER         := FND_API.G_MISS_NUM
, Number48                 NUMBER         := FND_API.G_MISS_NUM
, Number49                 NUMBER         := FND_API.G_MISS_NUM
, Number50                 NUMBER         := FND_API.G_MISS_NUM
, Date01                   DATE           := FND_API.G_MISS_DATE
, Date02                   DATE           := FND_API.G_MISS_DATE
, Date03                   DATE           := FND_API.G_MISS_DATE
, Date04                   DATE           := FND_API.G_MISS_DATE
, Date05                   DATE           := FND_API.G_MISS_DATE
, Date06                   DATE           := FND_API.G_MISS_DATE
, Date07                   DATE           := FND_API.G_MISS_DATE
, Date08                   DATE           := FND_API.G_MISS_DATE
, Date09                   DATE           := FND_API.G_MISS_DATE
, Date10                   DATE           := FND_API.G_MISS_DATE
, Date11                   DATE           := FND_API.G_MISS_DATE
, Date12                   DATE           := FND_API.G_MISS_DATE
, Date13                   DATE           := FND_API.G_MISS_DATE
, Date14                   DATE           := FND_API.G_MISS_DATE
, Date15                   DATE           := FND_API.G_MISS_DATE
, Date16                   DATE           := FND_API.G_MISS_DATE
, Date17                   DATE           := FND_API.G_MISS_DATE
, Date18                   DATE           := FND_API.G_MISS_DATE
, Date19                   DATE           := FND_API.G_MISS_DATE
, Date20                   DATE           := FND_API.G_MISS_DATE
, Date21                   DATE           := FND_API.G_MISS_DATE
, Date22                   DATE           := FND_API.G_MISS_DATE
, Date23                   DATE           := FND_API.G_MISS_DATE
, Date24                   DATE           := FND_API.G_MISS_DATE
, Date25                   DATE           := FND_API.G_MISS_DATE
, Date26                   DATE           := FND_API.G_MISS_DATE
, Date27                   DATE           := FND_API.G_MISS_DATE
, Date28                   DATE           := FND_API.G_MISS_DATE
, Date29                   DATE           := FND_API.G_MISS_DATE
, Date30                   DATE           := FND_API.G_MISS_DATE
, Date31                   DATE           := FND_API.G_MISS_DATE
, Date32                   DATE           := FND_API.G_MISS_DATE
, Date33                   DATE           := FND_API.G_MISS_DATE
, Date34                   DATE           := FND_API.G_MISS_DATE
, Date35                   DATE           := FND_API.G_MISS_DATE
, Date36                   DATE           := FND_API.G_MISS_DATE
, Date37                   DATE           := FND_API.G_MISS_DATE
, Date38                   DATE           := FND_API.G_MISS_DATE
, Date39                   DATE           := FND_API.G_MISS_DATE
, Date40                   DATE           := FND_API.G_MISS_DATE
, Date41                   DATE           := FND_API.G_MISS_DATE
, Date42                   DATE           := FND_API.G_MISS_DATE
, Date43                   DATE           := FND_API.G_MISS_DATE
, Date44                   DATE           := FND_API.G_MISS_DATE
, Date45                   DATE           := FND_API.G_MISS_DATE
, Date46                   DATE           := FND_API.G_MISS_DATE
, Date47                   DATE           := FND_API.G_MISS_DATE
, Date48                   DATE           := FND_API.G_MISS_DATE
, Date49                   DATE           := FND_API.G_MISS_DATE
, Date50                   DATE           := FND_API.G_MISS_DATE
);

TYPE PFL_Tbl_Type IS TABLE OF PFL_Rec_Type
  INDEX BY BINARY_INTEGER;


--
--  API Name      : Create_Print_Form
--  Type          : Public
--  Pre-reqs      : None
--  Function      : Creates a new instances of a print form
--
--  Parameters    :
--  IN            : p_api_version            NUMBER
--                  p_commit                 VARCHAR2
--                  p_init_msg_list          VARCHAR2
--                  p_header_rec             PFH_Rec_Type
--                  p_line_tbl               PFL_Tbl_Type
--  OUT           : x_form_header_id         NUMBER
--                    Primary Key of print form header, if
--                    successfully created
--                  x_msg_count              NUMBER
--                  x_msg_data               VARCHAR2
--                  x_return_status          VARCHAR2
--
--  Version       : Current Version - 1.0
--                  Initial Version - 1.0
--
PROCEDURE Create_Print_Form
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2
,  p_init_msg_list          IN    VARCHAR2
,  x_msg_count              OUT NOCOPY   NUMBER
,  x_msg_data               OUT NOCOPY   VARCHAR2
,  x_return_status          OUT NOCOPY   VARCHAR2
,  p_header_rec             IN    PFH_Rec_Type
,  p_line_tbl               IN    PFL_Tbl_Type
,  x_form_header_id         OUT NOCOPY   NUMBER
);


--
--  API Name      : Create_Print_Form
--  Type          : Public
--  Pre-reqs      : None
--  Function      : Updates an existing instance of a print form
--
--  Parameters    :
--  IN            : p_api_version            NUMBER
--                  p_commit                 VARCHAR2
--                  p_init_msg_list          VARCHAR2
--                  p_header_rec             PFH_Rec_Type
--                  p_line_tbl               PFL_Tbl_Type
--  OUT           : x_msg_count              NUMBER
--                  x_msg_data               VARCHAR2
--                  x_return_status          VARCHAR2
--
--  Version       : Current Version - 1.0
--                  Initial Version - 1.0
--
PROCEDURE Update_Print_Form
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2
,  p_init_msg_list          IN    VARCHAR2
,  x_msg_count              OUT NOCOPY   NUMBER
,  x_msg_data               OUT NOCOPY   VARCHAR2
,  x_return_status          OUT NOCOPY   VARCHAR2
,  p_header_rec             IN    PFH_Rec_Type
,  p_line_tbl               IN    PFL_Tbl_Type
);

END oke_print_form_pub;

 

/
