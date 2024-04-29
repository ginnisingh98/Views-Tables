--------------------------------------------------------
--  DDL for Package Body RG_DSS_VAR_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_VAR_TEMPLATES_PKG" as
/*$Header: rgidvtlb.pls 120.3 2003/04/29 00:47:35 djogg ship $*/

FUNCTION validate_templates(X_Variable_Id NUMBER) RETURN VARCHAR2 IS
X_Segment1	  VARCHAR2(25);
X_Segment2	  VARCHAR2(25);
X_Segment3	  VARCHAR2(25);
X_Segment4	  VARCHAR2(25);
X_Segment5	  VARCHAR2(25);
X_Segment6	  VARCHAR2(25);
X_Segment7	  VARCHAR2(25);
X_Segment8	  VARCHAR2(25);
X_Segment9	  VARCHAR2(25);
X_Segment10	  VARCHAR2(25);
X_Segment11	  VARCHAR2(25);
X_Segment12	  VARCHAR2(25);
X_Segment13	  VARCHAR2(25);
X_Segment14	  VARCHAR2(25);
X_Segment15	  VARCHAR2(25);
X_Segment16	  VARCHAR2(25);
X_Segment17	  VARCHAR2(25);
X_Segment18	  VARCHAR2(25);
X_Segment19	  VARCHAR2(25);
X_Segment20	  VARCHAR2(25);
X_Segment21	  VARCHAR2(25);
X_Segment22	  VARCHAR2(25);
X_Segment23	  VARCHAR2(25);
X_Segment24	  VARCHAR2(25);
X_Segment25	  VARCHAR2(25);
X_Segment26	  VARCHAR2(25);
X_Segment27	  VARCHAR2(25);
X_Segment28	  VARCHAR2(25);
X_Segment29	  VARCHAR2(25);
X_Segment30	  VARCHAR2(25);
dummy             VARCHAR2(10);
BEGIN
	SELECT
                 segment1_type,
                 segment2_type,
                 segment3_type,
                 segment4_type,
                 segment5_type,
                 segment6_type,
                 segment7_type,
                 segment8_type,
                 segment9_type,
                 segment10_type,
                 segment11_type,
                 segment12_type,
                 segment13_type,
                 segment14_type,
                 segment15_type,
                 segment16_type,
                 segment17_type,
                 segment18_type,
                 segment19_type,
                 segment20_type,
                 segment21_type,
                 segment22_type,
                 segment23_type,
                 segment24_type,
                 segment25_type,
                 segment26_type,
                 segment27_type,
                 segment28_type,
                 segment29_type,
                 segment30_type
        INTO
                 X_Segment1,
                 X_Segment2,
                 X_Segment3,
                 X_Segment4,
                 X_Segment5,
                 X_Segment6,
                 X_Segment7,
                 X_Segment8,
                 X_Segment9,
                 X_Segment10,
                 X_Segment11,
                 X_Segment12,
                 X_Segment13,
                 X_Segment14,
                 X_Segment15,
                 X_Segment16,
                 X_Segment17,
                 X_Segment18,
                 X_Segment19,
                 X_Segment20,
                 X_Segment21,
                 X_Segment22,
                 X_Segment23,
                 X_Segment24,
                 X_Segment25,
                 X_Segment26,
                 X_Segment27,
                 X_Segment28,
                 X_Segment29,
                 X_Segment30
	FROM  rg_dss_variables
        WHERE variable_id = X_Variable_Id;

     BEGIN
	SELECT 'exist'
        INTO   dummy
        FROM   dual
	WHERE  exists (
          SELECT 'x'
          FROM  rg_dss_var_templates
	  WHERE variable_id = X_Variable_Id );
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          return('I');
     END;

     BEGIN
	SELECT 'Invalid'
        INTO   dummy
        FROM   dual
	WHERE  exists (
          SELECT 'Bad'
          FROM  rg_dss_var_templates
	  WHERE
                variable_id = X_Variable_Id
          AND (   instr(decode(X_Segment1,'ANY','DTR',X_Segment1),
                        decode(Segment1_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment2,'ANY','DTR',X_Segment2),
                        decode(Segment2_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment3,'ANY','DTR',X_Segment3),
                        decode(Segment3_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment4,'ANY','DTR',X_Segment4),
                        decode(Segment4_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment5,'ANY','DTR',X_Segment5),
                        decode(Segment5_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment6,'ANY','DTR',X_Segment6),
                        decode(Segment6_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment7,'ANY','DTR',X_Segment7),
                        decode(Segment7_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment8,'ANY','DTR',X_Segment8),
                        decode(Segment8_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment9,'ANY','DTR',X_Segment9),
                        decode(Segment9_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment10,'ANY','DTR',X_Segment10),
                        decode(Segment10_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment11,'ANY','DTR',X_Segment11),
                        decode(Segment11_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment12,'ANY','DTR',X_Segment12),
                        decode(Segment12_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment13,'ANY','DTR',X_Segment13),
                        decode(Segment13_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment14,'ANY','DTR',X_Segment14),
                        decode(Segment14_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment15,'ANY','DTR',X_Segment15),
                        decode(Segment15_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment16,'ANY','DTR',X_Segment16),
                        decode(Segment16_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment17,'ANY','DTR',X_Segment17),
                        decode(Segment17_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment18,'ANY','DTR',X_Segment18),
                        decode(Segment18_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment19,'ANY','DTR',X_Segment19),
                        decode(Segment19_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment20,'ANY','DTR',X_Segment20),
                        decode(Segment20_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment21,'ANY','DTR',X_Segment21),
                        decode(Segment21_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment22,'ANY','DTR',X_Segment22),
                        decode(Segment22_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment23,'ANY','DTR',X_Segment23),
                        decode(Segment23_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment24,'ANY','DTR',X_Segment24),
                        decode(Segment24_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment25,'ANY','DTR',X_Segment25),
                        decode(Segment25_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment26,'ANY','DTR',X_Segment26),
                        decode(Segment26_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment27,'ANY','DTR',X_Segment27),
                        decode(Segment27_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment28,'ANY','DTR',X_Segment28),
                        decode(Segment28_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment29,'ANY','DTR',X_Segment29),
                        decode(Segment29_Type,'D','D','T','T','R')) = 0
              OR  instr(decode(X_Segment30,'ANY','DTR',X_Segment30),
                        decode(Segment30_Type,'D','D','T','T','R')) = 0
          ));

     return('I');

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return('V');
     END;

END validate_templates;


  PROCEDURE Get_New_Template_Id(
                 X_Variable_Id                    NUMBER,
                 X_Template_Id                    NUMBER,
                 X_Ledger_Id                         NUMBER,
                 X_New_Template_Id         IN OUT NOCOPY NUMBER,
                 X_New_Template_Name       IN OUT NOCOPY VARCHAR2 ) IS
  BEGIN
	SELECT st.template_id,st.template_name
        INTO   X_New_Template_Id,X_New_Template_Name
	FROM	GL_SUMMARY_TEMPLATES st,
                RG_DSS_VAR_TEMPLATES vt
	WHERE	vt.variable_id = X_Variable_Id
        AND     vt.template_id = X_Template_Id
        AND     st.ledger_id = X_Ledger_Id
        AND     st.status = 'F'
        AND     nvl(vt.segment1_type,'x') = nvl(st.segment1_type,'x')
        AND     nvl(vt.segment2_type,'x') = nvl(st.segment2_type,'x')
        AND     nvl(vt.segment3_type,'x') = nvl(st.segment3_type,'x')
        AND     nvl(vt.segment4_type,'x') = nvl(st.segment4_type,'x')
        AND     nvl(vt.segment5_type,'x') = nvl(st.segment5_type,'x')
        AND     nvl(vt.segment6_type,'x') = nvl(st.segment6_type,'x')
        AND     nvl(vt.segment7_type,'x') = nvl(st.segment7_type,'x')
        AND     nvl(vt.segment8_type,'x') = nvl(st.segment8_type,'x')
        AND     nvl(vt.segment9_type,'x') = nvl(st.segment9_type,'x')
        AND     nvl(vt.segment10_type,'x') = nvl(st.segment10_type,'x')
        AND     nvl(vt.segment11_type,'x') = nvl(st.segment11_type,'x')
        AND     nvl(vt.segment12_type,'x') = nvl(st.segment12_type,'x')
        AND     nvl(vt.segment13_type,'x') = nvl(st.segment13_type,'x')
        AND     nvl(vt.segment14_type,'x') = nvl(st.segment14_type,'x')
        AND     nvl(vt.segment15_type,'x') = nvl(st.segment15_type,'x')
        AND     nvl(vt.segment16_type,'x') = nvl(st.segment16_type,'x')
        AND     nvl(vt.segment17_type,'x') = nvl(st.segment17_type,'x')
        AND     nvl(vt.segment18_type,'x') = nvl(st.segment18_type,'x')
        AND     nvl(vt.segment19_type,'x') = nvl(st.segment19_type,'x')
        AND     nvl(vt.segment20_type,'x') = nvl(st.segment20_type,'x')
        AND     nvl(vt.segment21_type,'x') = nvl(st.segment21_type,'x')
        AND     nvl(vt.segment22_type,'x') = nvl(st.segment22_type,'x')
        AND     nvl(vt.segment23_type,'x') = nvl(st.segment23_type,'x')
        AND     nvl(vt.segment24_type,'x') = nvl(st.segment24_type,'x')
        AND     nvl(vt.segment25_type,'x') = nvl(st.segment25_type,'x')
        AND     nvl(vt.segment26_type,'x') = nvl(st.segment26_type,'x')
        AND     nvl(vt.segment27_type,'x') = nvl(st.segment27_type,'x')
        AND     nvl(vt.segment28_type,'x') = nvl(st.segment28_type,'x')
        AND     nvl(vt.segment29_type,'x') = nvl(st.segment29_type,'x')
        AND     nvl(vt.segment30_type,'x') = nvl(st.segment30_type,'x');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        X_New_Template_Id := -1;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'RG_DSS_VAR_TEMPLATES.Get_New_Template_Id');
      RAISE;
  END Get_New_Template_Id;

PROCEDURE check_unique_template(X_Rowid VARCHAR2,
                                X_Variable_Id NUMBER,
                                X_Template_Id NUMBER) IS
  dummy   NUMBER;
BEGIN
  SELECT    1
  INTO      dummy
  FROM      rg_dss_var_templates
  WHERE     variable_id = X_Variable_Id
  AND       template_id = X_Template_Id
  AND       ((X_Rowid IS NULL) OR (rowid <> X_Rowid));

  -- name already exists for a different variable: ERROR
  FND_MESSAGE.set_name('RG', 'RG_FORMS_OBJECT_EXISTS_FOR');
  FND_MESSAGE.set_token('OBJECT1', 'RG_DSS_TEMPLATE', TRUE);
  FND_MESSAGE.set_token('OBJECT2', 'RG_DSS_VARIABLE', TRUE);
  APP_EXCEPTION.raise_exception;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END check_unique_template;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Variable_Id                    NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Segment1_Type                  VARCHAR2,
                       X_Segment2_Type                  VARCHAR2,
                       X_Segment3_Type                  VARCHAR2,
                       X_Segment4_Type                  VARCHAR2,
                       X_Segment5_Type                  VARCHAR2,
                       X_Segment6_Type                  VARCHAR2,
                       X_Segment7_Type                  VARCHAR2,
                       X_Segment8_Type                  VARCHAR2,
                       X_Segment9_Type                  VARCHAR2,
                       X_Segment10_Type                 VARCHAR2,
                       X_Segment11_Type                 VARCHAR2,
                       X_Segment12_Type                 VARCHAR2,
                       X_Segment13_Type                 VARCHAR2,
                       X_Segment14_Type                 VARCHAR2,
                       X_Segment15_Type                 VARCHAR2,
                       X_Segment16_Type                 VARCHAR2,
                       X_Segment17_Type                 VARCHAR2,
                       X_Segment18_Type                 VARCHAR2,
                       X_Segment19_Type                 VARCHAR2,
                       X_Segment20_Type                 VARCHAR2,
                       X_Segment21_Type                 VARCHAR2,
                       X_Segment22_Type                 VARCHAR2,
                       X_Segment23_Type                 VARCHAR2,
                       X_Segment24_Type                 VARCHAR2,
                       X_Segment25_Type                 VARCHAR2,
                       X_Segment26_Type                 VARCHAR2,
                       X_Segment27_Type                 VARCHAR2,
                       X_Segment28_Type                 VARCHAR2,
                       X_Segment29_Type                 VARCHAR2,
                       X_Segment30_Type                 VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM RG_DSS_VAR_TEMPLATES
                 WHERE variable_id = X_Variable_Id
                 AND   template_id = X_Template_Id;
   BEGIN

       check_unique_template(X_Rowid, X_Variable_Id, X_Template_Id);

       INSERT INTO RG_DSS_VAR_TEMPLATES(
              variable_id,
              template_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              creation_date,
              created_by,
              segment1_type,
              segment2_type,
              segment3_type,
              segment4_type,
              segment5_type,
              segment6_type,
              segment7_type,
              segment8_type,
              segment9_type,
              segment10_type,
              segment11_type,
              segment12_type,
              segment13_type,
              segment14_type,
              segment15_type,
              segment16_type,
              segment17_type,
              segment18_type,
              segment19_type,
              segment20_type,
              segment21_type,
              segment22_type,
              segment23_type,
              segment24_type,
              segment25_type,
              segment26_type,
              segment27_type,
              segment28_type,
              segment29_type,
              segment30_type,
              context,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             ) VALUES (
              X_Variable_Id,
              X_Template_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Segment1_Type,
              X_Segment2_Type,
              X_Segment3_Type,
              X_Segment4_Type,
              X_Segment5_Type,
              X_Segment6_Type,
              X_Segment7_Type,
              X_Segment8_Type,
              X_Segment9_Type,
              X_Segment10_Type,
              X_Segment11_Type,
              X_Segment12_Type,
              X_Segment13_Type,
              X_Segment14_Type,
              X_Segment15_Type,
              X_Segment16_Type,
              X_Segment17_Type,
              X_Segment18_Type,
              X_Segment19_Type,
              X_Segment20_Type,
              X_Segment21_Type,
              X_Segment22_Type,
              X_Segment23_Type,
              X_Segment24_Type,
              X_Segment25_Type,
              X_Segment26_Type,
              X_Segment27_Type,
              X_Segment28_Type,
              X_Segment29_Type,
              X_Segment30_Type,
              X_Context,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Variable_Id                      NUMBER,
                     X_Template_Id                      NUMBER,
                     X_Segment1_Type                    VARCHAR2,
                     X_Segment2_Type                    VARCHAR2,
                     X_Segment3_Type                    VARCHAR2,
                     X_Segment4_Type                    VARCHAR2,
                     X_Segment5_Type                    VARCHAR2,
                     X_Segment6_Type                    VARCHAR2,
                     X_Segment7_Type                    VARCHAR2,
                     X_Segment8_Type                    VARCHAR2,
                     X_Segment9_Type                    VARCHAR2,
                     X_Segment10_Type                   VARCHAR2,
                     X_Segment11_Type                   VARCHAR2,
                     X_Segment12_Type                   VARCHAR2,
                     X_Segment13_Type                   VARCHAR2,
                     X_Segment14_Type                   VARCHAR2,
                     X_Segment15_Type                   VARCHAR2,
                     X_Segment16_Type                   VARCHAR2,
                     X_Segment17_Type                   VARCHAR2,
                     X_Segment18_Type                   VARCHAR2,
                     X_Segment19_Type                   VARCHAR2,
                     X_Segment20_Type                   VARCHAR2,
                     X_Segment21_Type                   VARCHAR2,
                     X_Segment22_Type                   VARCHAR2,
                     X_Segment23_Type                   VARCHAR2,
                     X_Segment24_Type                   VARCHAR2,
                     X_Segment25_Type                   VARCHAR2,
                     X_Segment26_Type                   VARCHAR2,
                     X_Segment27_Type                   VARCHAR2,
                     X_Segment28_Type                   VARCHAR2,
                     X_Segment29_Type                   VARCHAR2,
                     X_Segment30_Type                   VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   RG_DSS_VAR_TEMPLATES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Variable_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.variable_id =  X_Variable_Id)
           AND (Recinfo.template_id =  X_Template_Id)
           AND (   (Recinfo.segment1_type =  X_Segment1_Type)
                OR (    (Recinfo.segment1_type IS NULL)
                    AND (X_Segment1_Type IS NULL)))
           AND (   (Recinfo.segment2_type =  X_Segment2_Type)
                OR (    (Recinfo.segment2_type IS NULL)
                    AND (X_Segment2_Type IS NULL)))
           AND (   (Recinfo.segment3_type =  X_Segment3_Type)
                OR (    (Recinfo.segment3_type IS NULL)
                    AND (X_Segment3_Type IS NULL)))
           AND (   (Recinfo.segment4_type =  X_Segment4_Type)
                OR (    (Recinfo.segment4_type IS NULL)
                    AND (X_Segment4_Type IS NULL)))
           AND (   (Recinfo.segment5_type =  X_Segment5_Type)
                OR (    (Recinfo.segment5_type IS NULL)
                    AND (X_Segment5_Type IS NULL)))
           AND (   (Recinfo.segment6_type =  X_Segment6_Type)
                OR (    (Recinfo.segment6_type IS NULL)
                    AND (X_Segment6_Type IS NULL)))
           AND (   (Recinfo.segment7_type =  X_Segment7_Type)
                OR (    (Recinfo.segment7_type IS NULL)
                    AND (X_Segment7_Type IS NULL)))
           AND (   (Recinfo.segment8_type =  X_Segment8_Type)
                OR (    (Recinfo.segment8_type IS NULL)
                    AND (X_Segment8_Type IS NULL)))
           AND (   (Recinfo.segment9_type =  X_Segment9_Type)
                OR (    (Recinfo.segment9_type IS NULL)
                    AND (X_Segment9_Type IS NULL)))
           AND (   (Recinfo.segment10_type =  X_Segment10_Type)
                OR (    (Recinfo.segment10_type IS NULL)
                    AND (X_Segment10_Type IS NULL)))
           AND (   (Recinfo.segment11_type =  X_Segment11_Type)
                OR (    (Recinfo.segment11_type IS NULL)
                    AND (X_Segment11_Type IS NULL)))
           AND (   (Recinfo.segment12_type =  X_Segment12_Type)
                OR (    (Recinfo.segment12_type IS NULL)
                    AND (X_Segment12_Type IS NULL)))
           AND (   (Recinfo.segment13_type =  X_Segment13_Type)
                OR (    (Recinfo.segment13_type IS NULL)
                    AND (X_Segment13_Type IS NULL)))
           AND (   (Recinfo.segment14_type =  X_Segment14_Type)
                OR (    (Recinfo.segment14_type IS NULL)
                    AND (X_Segment14_Type IS NULL)))
           AND (   (Recinfo.segment15_type =  X_Segment15_Type)
                OR (    (Recinfo.segment15_type IS NULL)
                    AND (X_Segment15_Type IS NULL)))
           AND (   (Recinfo.segment16_type =  X_Segment16_Type)
                OR (    (Recinfo.segment16_type IS NULL)
                    AND (X_Segment16_Type IS NULL)))
           AND (   (Recinfo.segment17_type =  X_Segment17_Type)
                OR (    (Recinfo.segment17_type IS NULL)
                    AND (X_Segment17_Type IS NULL)))
           AND (   (Recinfo.segment18_type =  X_Segment18_Type)
                OR (    (Recinfo.segment18_type IS NULL)
                    AND (X_Segment18_Type IS NULL)))
           AND (   (Recinfo.segment19_type =  X_Segment19_Type)
                OR (    (Recinfo.segment19_type IS NULL)
                    AND (X_Segment19_Type IS NULL)))
           AND (   (Recinfo.segment20_type =  X_Segment20_Type)
                OR (    (Recinfo.segment20_type IS NULL)
                    AND (X_Segment20_Type IS NULL)))
           AND (   (Recinfo.segment21_type =  X_Segment21_Type)
                OR (    (Recinfo.segment21_type IS NULL)
                    AND (X_Segment21_Type IS NULL)))
           AND (   (Recinfo.segment22_type =  X_Segment22_Type)
                OR (    (Recinfo.segment22_type IS NULL)
                    AND (X_Segment22_Type IS NULL)))
           AND (   (Recinfo.segment23_type =  X_Segment23_Type)
                OR (    (Recinfo.segment23_type IS NULL)
                    AND (X_Segment23_Type IS NULL)))
           AND (   (Recinfo.segment24_type =  X_Segment24_Type)
                OR (    (Recinfo.segment24_type IS NULL)
                    AND (X_Segment24_Type IS NULL)))
           AND (   (Recinfo.segment25_type =  X_Segment25_Type)
                OR (    (Recinfo.segment25_type IS NULL)
                    AND (X_Segment25_Type IS NULL)))
           AND (   (Recinfo.segment26_type =  X_Segment26_Type)
                OR (    (Recinfo.segment26_type IS NULL)
                    AND (X_Segment26_Type IS NULL)))
           AND (   (Recinfo.segment27_type =  X_Segment27_Type)
                OR (    (Recinfo.segment27_type IS NULL)
                    AND (X_Segment27_Type IS NULL)))
           AND (   (Recinfo.segment28_type =  X_Segment28_Type)
                OR (    (Recinfo.segment28_type IS NULL)
                    AND (X_Segment28_Type IS NULL)))
           AND (   (Recinfo.segment29_type =  X_Segment29_Type)
                OR (    (Recinfo.segment29_type IS NULL)
                    AND (X_Segment29_Type IS NULL)))
           AND (   (Recinfo.segment30_type =  X_Segment30_Type)
                OR (    (Recinfo.segment30_type IS NULL)
                    AND (X_Segment30_Type IS NULL)))
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Variable_Id                    NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Segment1_Type                  VARCHAR2,
                       X_Segment2_Type                  VARCHAR2,
                       X_Segment3_Type                  VARCHAR2,
                       X_Segment4_Type                  VARCHAR2,
                       X_Segment5_Type                  VARCHAR2,
                       X_Segment6_Type                  VARCHAR2,
                       X_Segment7_Type                  VARCHAR2,
                       X_Segment8_Type                  VARCHAR2,
                       X_Segment9_Type                  VARCHAR2,
                       X_Segment10_Type                 VARCHAR2,
                       X_Segment11_Type                 VARCHAR2,
                       X_Segment12_Type                 VARCHAR2,
                       X_Segment13_Type                 VARCHAR2,
                       X_Segment14_Type                 VARCHAR2,
                       X_Segment15_Type                 VARCHAR2,
                       X_Segment16_Type                 VARCHAR2,
                       X_Segment17_Type                 VARCHAR2,
                       X_Segment18_Type                 VARCHAR2,
                       X_Segment19_Type                 VARCHAR2,
                       X_Segment20_Type                 VARCHAR2,
                       X_Segment21_Type                 VARCHAR2,
                       X_Segment22_Type                 VARCHAR2,
                       X_Segment23_Type                 VARCHAR2,
                       X_Segment24_Type                 VARCHAR2,
                       X_Segment25_Type                 VARCHAR2,
                       X_Segment26_Type                 VARCHAR2,
                       X_Segment27_Type                 VARCHAR2,
                       X_Segment28_Type                 VARCHAR2,
                       X_Segment29_Type                 VARCHAR2,
                       X_Segment30_Type                 VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
  BEGIN
    UPDATE RG_DSS_VAR_TEMPLATES
    SET
       variable_id                     =     X_Variable_Id,
       template_id                     =     X_Template_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       segment1_type                   =     X_Segment1_Type,
       segment2_type                   =     X_Segment2_Type,
       segment3_type                   =     X_Segment3_Type,
       segment4_type                   =     X_Segment4_Type,
       segment5_type                   =     X_Segment5_Type,
       segment6_type                   =     X_Segment6_Type,
       segment7_type                   =     X_Segment7_Type,
       segment8_type                   =     X_Segment8_Type,
       segment9_type                   =     X_Segment9_Type,
       segment10_type                  =     X_Segment10_Type,
       segment11_type                  =     X_Segment11_Type,
       segment12_type                  =     X_Segment12_Type,
       segment13_type                  =     X_Segment13_Type,
       segment14_type                  =     X_Segment14_Type,
       segment15_type                  =     X_Segment15_Type,
       segment16_type                  =     X_Segment16_Type,
       segment17_type                  =     X_Segment17_Type,
       segment18_type                  =     X_Segment18_Type,
       segment19_type                  =     X_Segment19_Type,
       segment20_type                  =     X_Segment20_Type,
       segment21_type                  =     X_Segment21_Type,
       segment22_type                  =     X_Segment22_Type,
       segment23_type                  =     X_Segment23_Type,
       segment24_type                  =     X_Segment24_Type,
       segment25_type                  =     X_Segment25_Type,
       segment26_type                  =     X_Segment26_Type,
       segment27_type                  =     X_Segment27_Type,
       segment28_type                  =     X_Segment28_Type,
       segment29_type                  =     X_Segment29_Type,
       segment30_type                  =     X_Segment30_Type,
       context                         =     X_Context,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM RG_DSS_VAR_TEMPLATES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END RG_DSS_VAR_TEMPLATES_PKG;

/
