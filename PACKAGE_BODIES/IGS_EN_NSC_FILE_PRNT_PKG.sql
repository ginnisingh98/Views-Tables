--------------------------------------------------------
--  DDL for Package Body IGS_EN_NSC_FILE_PRNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_NSC_FILE_PRNT_PKG" AS
/* $Header: IGSEN89B.pls 115.6 2002/11/29 00:12:39 nsidana noship $ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'IGS_EN_NSC_FILE_PRNT_PKG';
g_prod             VARCHAR2(3)           := 'IGS';
g_debug_mode       BOOLEAN := TRUE;

-- Type of group list description
TYPE group_list_type IS RECORD (
   pk_attrib_id        igs_en_attrib_values.attrib_id%TYPE, --PK attrib which provides versions for the loop
   ord_by_attrib_id    igs_en_attrib_values.attrib_id%TYPE, --Odrer by attrib id
   attrib_amount       NUMBER, --Amount of the described attribs in the table
   attrib_start_index  NUMBER ); --Start index in the table with the attrib info


-- Type of table of group list description

TYPE group_list_tbl_type IS TABLE OF group_list_type
    INDEX BY BINARY_INTEGER;

-- Type of attrib list description
TYPE attrib_list_type IS RECORD (
   attrib_id        igs_en_attrib_values.attrib_id%TYPE, --ID of the attribute. If 0 - then attrib is a constant and has a default value
   len              NUMBER  (10), -- Lenght of the full value
   format_mask      VARCHAR2(30), -- Not used
   empty_space_fill VARCHAR2(1) , -- If the  value length is less then provided then the rest is filled with this character
   pre_attrib_char  VARCHAR2(1) , -- Character added before the value
   post_attrib_char VARCHAR2(1) , -- Character added after the value
   align            VARCHAR2(1) , -- Alighnment currently only 'L'eft or 'R'ight supported
   default_val      VARCHAR2(255)); --Default value of the value is NULL

-- Type of table of attrib list description

TYPE attrib_list_tbl_type IS TABLE OF attrib_list_type
    INDEX BY BINARY_INTEGER;

PROCEDURE Put_Debug_Msg (
   p_debug_message IN VARCHAR2
);

FUNCTION Format_Attrib (
  p_obj_type_id IN igs_en_attrib_values.obj_type_id%TYPE ,
  p_obj_id      IN igs_en_attrib_values.obj_id%TYPE      ,
  p_version     IN igs_en_attrib_values.version%TYPE     ,
  p_attr_def    IN attrib_list_type
)RETURN VARCHAR2;



PROCEDURE Init_format_data (
   p_form_id      IN  NUMBER, --Not used in the current implementation
   x_total_groups OUT NOCOPY NUMBER,
   x_group_list   OUT NOCOPY group_list_tbl_type,
   x_attr_list    OUT NOCOPY attrib_list_tbl_type
);

/* Main public procedure which is called for the printing */

PROCEDURE Generate_file(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_obj_type_id       IN   NUMBER,
  p_doc_inst_id       IN   NUMBER,
  p_dirpath           IN   VARCHAR2,
  p_file_name         IN   VARCHAR2,
  p_form_id           IN   NUMBER ,
  p_debug_mode        IN   VARCHAR2 := FND_API.G_FALSE
)
IS

 l_api_name         CONSTANT VARCHAR2(30)   := 'Generate_file';
 l_file_ptr         UTL_FILE.FILE_TYPE;
 l_attr_list        attrib_list_tbl_type;
 l_group_list       group_list_tbl_type;
 l_total_groups     NUMBER(10);
 l_group_count      NUMBER(10);
 l_attrib_count     NUMBER(10);
 l_line             VARCHAR2(2000);
 l_attr_val         VARCHAR2(255);

 CURSOR c_group_vers (c_pk_id NUMBER, c_ord_id NUMBER) IS
    SELECT pk_tbl.version
     FROM igs_en_attrib_values pk_tbl,
          igs_en_attrib_values ord_tbl
    WHERE pk_tbl.obj_type_id     = ord_tbl.obj_type_id (+)
          AND pk_tbl.obj_id      = ord_tbl.obj_id  (+)
          AND pk_tbl.version     = ord_tbl.version (+)
          AND pk_tbl.obj_id      = p_doc_inst_id
          AND pk_tbl.obj_type_id = p_obj_type_id
          AND pk_tbl.attrib_id   = c_pk_id
          AND ord_tbl.attrib_id  = c_ord_id
    ORDER BY ord_tbl.value;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Generate_file;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ('1.0',
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  g_debug_mode := FND_API.TO_BOOLEAN(p_debug_mode);
  --Opening file
  Put_Debug_Msg('Opening file: '||p_dirpath||p_file_name);

  l_file_ptr  := UTL_FILE.FOPEN ( p_dirpath, p_file_name, 'a' );

  Put_Debug_Msg('Init visual data');
  --Init visual data
  Init_format_data (
     p_form_id      => 1             ,
     x_total_groups => l_total_groups,
     x_group_list   => l_group_list  ,
     x_attr_list    => l_attr_list   );


  -- Group Loop
  Put_Debug_Msg('Loop through all groups');
  FOR l_group_count IN 1..l_total_groups LOOP

     -- Loop throug all version of the PK attrib in the group

     FOR c_group_vers_rec IN
        c_group_vers( l_group_list(l_group_count).pk_attrib_id,l_group_list(l_group_count).ord_by_attrib_id )
        LOOP -- Versions list


        --Init the line - max 200 characters
        l_line := '';

        --Loop through all attributes in the group

        FOR l_attrib_count IN l_group_list(l_group_count).attrib_start_index..(
            l_group_list(l_group_count).attrib_start_index + l_group_list(l_group_count).attrib_amount -1)
            LOOP --List of all attributes

            -- Get formatted value

            l_attr_val := Format_Attrib (
                             p_obj_type_id => p_obj_type_id,
                             p_obj_id      => p_doc_inst_id,
                             p_version     => c_group_vers_rec.version,
                             p_attr_def    => l_attr_list(l_attrib_count));

            l_line:= l_line||l_attr_val;

        END LOOP; --End of list of attributes

        -- Put line into the file

        UTL_FILE.PUT_LINE ( l_file_ptr, l_line );
        UTL_FILE.FFLUSH ( l_file_ptr );

     END LOOP; --End of versions list
  END LOOP;  -- End of Group Loop

  Put_Debug_Msg('Closing file');

  IF (UTL_FILE.IS_OPEN ( l_file_ptr )) THEN
      UTL_FILE.FCLOSE ( l_file_ptr );
  END IF;

EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
        ROLLBACK TO Generate_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_EN_INVALID_PATH');
        FND_MSG_PUB.Add;

 WHEN UTL_FILE.WRITE_ERROR THEN
        ROLLBACK TO Generate_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_EN_WRITE_ERROR');
        FND_MSG_PUB.Add;

 WHEN UTL_FILE.INVALID_FILEHANDLE  THEN
        ROLLBACK TO Generate_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_EN_INVALID_FILEHANDLE');
        FND_MSG_PUB.Add;

 WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO Generate_file;
     Put_Debug_Msg('EXC_ERROR exception');
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF (UTL_FILE.IS_OPEN ( l_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_file_ptr );
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO Generate_file;
     Put_Debug_Msg('UNEXPECTED_ERROR exception');

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (UTL_FILE.IS_OPEN ( l_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_file_ptr );
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO Generate_file;
     Put_Debug_Msg('Others exception');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

     IF (UTL_FILE.IS_OPEN ( l_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_file_ptr );
     END IF;

END Generate_file;

/* Procedure retrieves and formats the particular attribute value */

FUNCTION Format_Attrib (
  p_obj_type_id IN igs_en_attrib_values.obj_type_id%TYPE ,
  p_obj_id      IN igs_en_attrib_values.obj_id%TYPE      ,
  p_version     IN igs_en_attrib_values.version%TYPE     ,
  p_attr_def    IN attrib_list_type
)RETURN VARCHAR2
IS
l_value VARCHAR2(255);
l_ind   NUMBER(5);
l_len   NUMBER(5);
l_post_len NUMBER(5);
BEGIN

  --Getting value
  IF p_attr_def.attrib_id <> 0 THEN
    -- If the attrib ID is null -the it's not stored in the value table and
    -- represents the constant, written in the default value

    l_value := IGS_EN_GS_ATTRIB_VAL.Get_Value (
                p_obj_type_id      => p_obj_type_id,
                p_obj_id           => p_obj_id,
                p_attrib_id        => p_attr_def.attrib_id,
                p_version          => p_version
                ) ;
  END IF;

  -- Assigning default value if no value is found
  IF l_value IS NULL THEN
     l_value := p_attr_def.default_val;
  END IF;

  -- Check if the retrieved value plus lenght of the post and pre charachters in not more then given

  IF (NVL(length (l_value),0)+NVL(length (p_attr_def.post_attrib_char),0)+NVL(length (p_attr_def.pre_attrib_char),0) ) > p_attr_def.len  THEN
     l_value := substr (l_value,1,(p_attr_def.len-NVL(length (p_attr_def.post_attrib_char),0)-NVL(length (p_attr_def.pre_attrib_char),0)));
  END IF;


  --Checking the alignment and adding the char to the right side
  IF p_attr_def.align = 'R' THEN
     l_value := l_value ||p_attr_def.post_attrib_char;
     l_post_len := NVL(length (p_attr_def.pre_attrib_char),0);
  ELSE
     l_value := p_attr_def.pre_attrib_char || l_value;
     l_post_len := NVL(length (p_attr_def.post_attrib_char),0);
  END IF;

  l_len := NVL(length (l_value),0);


  --Adding characters to have the given length

  IF (l_len+l_post_len) < p_attr_def.len THEN
     FOR l_ind IN (l_len+1+l_post_len)..p_attr_def.len LOOP

        IF p_attr_def.align = 'R' THEN
           --Adding characters to the left side
           l_value := NVL(p_attr_def.empty_space_fill,' ')||l_value;
        ELSE
           l_value := l_value||NVL(p_attr_def.empty_space_fill,' ');
        END IF;

     END LOOP;
  END IF;

  IF p_attr_def.align = 'R' THEN
     l_value := p_attr_def.pre_attrib_char || l_value;
  ELSE
     l_value := l_value ||p_attr_def.post_attrib_char;
  END IF;
  -- One more check to make sure that left and rigt characters length is not more then the total

  RETURN substr(l_value,1,p_attr_def.len );

END Format_Attrib;


/* This procedure initializes the visual attributes of the output file */
/* For the Id list and visual representation see HLD and DLD */
PROCEDURE Init_format_data (
   p_form_id      IN  NUMBER, --Not used in the current implementation
   x_total_groups OUT NOCOPY NUMBER,
   x_group_list   OUT NOCOPY group_list_tbl_type,
   x_attr_list    OUT NOCOPY attrib_list_tbl_type
) IS
BEGIN

  x_total_groups := 3; --Total 3 groups: Header, Body Trailer

  x_group_list(1).pk_attrib_id := 1;
  x_group_list(1).ord_by_attrib_id := 1;
  x_group_list(1).attrib_start_index := 1;
  x_group_list(1).attrib_amount := 8;

  x_group_list(2).pk_attrib_id := 20;
  x_group_list(2).ord_by_attrib_id := 20;
  x_group_list(2).attrib_start_index := 30;
  x_group_list(2).attrib_amount := 23;

  x_group_list(3).pk_attrib_id := 10;
  x_group_list(3).ord_by_attrib_id := 10;
  x_group_list(3).attrib_start_index := 10;
  x_group_list(3).attrib_amount := 11;

  --Init header record
  x_attr_list(1).attrib_id := 0 ;
  x_attr_list(2).attrib_id := 1 ;
  x_attr_list(3).attrib_id := 2 ;
  x_attr_list(4).attrib_id := 3 ;
  x_attr_list(5).attrib_id := 5 ;
  x_attr_list(6).attrib_id := 6 ;
  x_attr_list(7).attrib_id := 0 ;
  x_attr_list(8).attrib_id := 0 ;

  x_attr_list(1).len := 2 ;
  x_attr_list(2).len := 6 ;
  x_attr_list(3).len := 2 ;
  x_attr_list(4).len := 15 ;
  x_attr_list(5).len := 1 ;
  x_attr_list(6).len := 8 ;
  x_attr_list(7).len := 1 ;
  x_attr_list(8).len := 215 ;

  x_attr_list(1).align := 'L' ;
  x_attr_list(2).align := 'L' ;
  x_attr_list(3).align := 'L' ;
  x_attr_list(4).align := 'L' ;
  x_attr_list(5).align := 'L' ;
  x_attr_list(6).align := 'L' ;
  x_attr_list(7).align := 'L' ;
  x_attr_list(8).align := 'L' ;

  x_attr_list(1).default_val := 'A1';
  x_attr_list(7).default_val := 'F';

  --Trailer
  x_attr_list(10).attrib_id := 0 ;
  x_attr_list(11).attrib_id := 10 ;
  x_attr_list(12).attrib_id := 11 ;
  x_attr_list(13).attrib_id := 12 ;
  x_attr_list(14).attrib_id := 13 ;
  x_attr_list(15).attrib_id := 14 ;
  x_attr_list(16).attrib_id := 15 ;
  x_attr_list(17).attrib_id := 16 ;
  x_attr_list(18).attrib_id := 17 ;
  x_attr_list(19).attrib_id := 18 ;
  x_attr_list(20).attrib_id := 0 ;

  x_attr_list(10).len := 2 ;
  x_attr_list(11).len := 6 ;
  x_attr_list(12).len := 6 ;
  x_attr_list(13).len := 6 ;
  x_attr_list(14).len := 6 ;
  x_attr_list(15).len := 6 ;
  x_attr_list(16).len := 6 ;
  x_attr_list(17).len := 6 ;
  x_attr_list(18).len := 6 ;
  x_attr_list(19).len := 8 ;
  x_attr_list(20).len := 192 ;

  x_attr_list(10).align := 'L' ;
  x_attr_list(11).align := 'L' ;
  x_attr_list(12).align := 'L' ;
  x_attr_list(13).align := 'L' ;
  x_attr_list(14).align := 'L' ;
  x_attr_list(15).align := 'L' ;
  x_attr_list(16).align := 'L' ;
  x_attr_list(17).align := 'L' ;
  x_attr_list(18).align := 'L' ;
  x_attr_list(19).align := 'L' ;
  x_attr_list(20).align := 'L' ;

  x_attr_list(10).default_val := 'T1';

  --Body
  x_attr_list(30).attrib_id := 0 ;
  x_attr_list(31).attrib_id :=  20;
  x_attr_list(32).attrib_id :=  21;
  x_attr_list(33).attrib_id :=  22;
  x_attr_list(34).attrib_id :=  23;
  x_attr_list(35).attrib_id :=  24;
  x_attr_list(36).attrib_id :=  25;
  x_attr_list(37).attrib_id :=  26;
  x_attr_list(38).attrib_id :=  27;
  x_attr_list(39).attrib_id :=  28;
  x_attr_list(40).attrib_id :=  29;
  x_attr_list(41).attrib_id :=  30;
  x_attr_list(42).attrib_id :=  31;
  x_attr_list(43).attrib_id :=  32;
  x_attr_list(44).attrib_id :=  33;
  x_attr_list(45).attrib_id :=  34;
  x_attr_list(46).attrib_id :=  35;
  x_attr_list(47).attrib_id :=  36;
  x_attr_list(48).attrib_id :=  37;
  x_attr_list(49).attrib_id :=  38;
  x_attr_list(50).attrib_id :=  39;
  x_attr_list(51).attrib_id :=  40;
  x_attr_list(52).attrib_id :=  0;

  x_attr_list(30).len := 2 ;
  x_attr_list(31).len := 9 ;
  x_attr_list(32).len := 20;
  x_attr_list(33).len := 1 ;
  x_attr_list(34).len := 20;
  x_attr_list(35).len := 5 ;
  x_attr_list(36).len := 9 ;
  x_attr_list(37).len := 20;
  x_attr_list(38).len := 1 ;
  x_attr_list(39).len := 8 ;
  x_attr_list(40).len := 30;
  x_attr_list(41).len := 30;
  x_attr_list(42).len := 20;
  x_attr_list(43).len := 2 ;
  x_attr_list(44).len := 9 ;
  x_attr_list(45).len := 15;
  x_attr_list(46).len := 8 ;
  x_attr_list(47).len := 8 ;
  x_attr_list(48).len := 8 ;
  x_attr_list(49).len := 8 ;
  x_attr_list(50).len := 1 ;
  x_attr_list(51).len := 1 ;
  x_attr_list(52).len := 15;

  x_attr_list(30).align := 'L' ;
  x_attr_list(31).align := 'L' ;
  x_attr_list(32).align := 'L' ;
  x_attr_list(33).align := 'L' ;
  x_attr_list(34).align := 'L' ;
  x_attr_list(35).align := 'L' ;
  x_attr_list(36).align := 'L' ;
  x_attr_list(37).align := 'L' ;
  x_attr_list(38).align := 'L' ;
  x_attr_list(39).align := 'L' ;
  x_attr_list(40).align := 'L' ;
  x_attr_list(41).align := 'L' ;
  x_attr_list(42).align := 'L' ;
  x_attr_list(43).align := 'L' ;
  x_attr_list(44).align := 'L' ;
  x_attr_list(45).align := 'L' ;
  x_attr_list(46).align := 'L' ;
  x_attr_list(47).align := 'L' ;
  x_attr_list(48).align := 'L' ;
  x_attr_list(49).align := 'L' ;
  x_attr_list(50).align := 'L' ;
  x_attr_list(51).align := 'L' ;
  x_attr_list(52).align := 'L' ;

  x_attr_list(30).default_val := 'D1';
  x_attr_list(16).empty_space_fill := '0'; --Zero fill required for this column

END Init_format_data;



  PROCEDURE Put_Debug_Msg (
    p_debug_message IN VARCHAR2
  ) IS
     l_api_name             CONSTANT VARCHAR2(30)   := 'Put_Debug_Message';
  BEGIN
    IF g_debug_mode THEN
      fnd_file.put_line(FND_FILE.LOG,p_debug_message);
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
       g_debug_mode := FALSE;
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

  END Put_Debug_Msg;

END IGS_EN_NSC_FILE_PRNT_PKG;

/
