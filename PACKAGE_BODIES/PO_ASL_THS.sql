--------------------------------------------------------
--  DDL for Package Body PO_ASL_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_THS" as
/* $Header: POXA2LSB.pls 120.4 2006/01/18 10:54:15 pthapliy noship $ */

-- <INBOUND LOGISTICS FPJ START>
g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_ASL_THS';
c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
-- <INBOUND LOGISTICS FPJ END>

/*=============================================================================

  PROCEDURE NAME:	insert_row()

===============================================================================*/
procedure insert_row(
	x_row_id		  IN OUT NOCOPY 	VARCHAR2,
	x_asl_id		  IN OUT	NOCOPY NUMBER,
	x_using_organization_id   		NUMBER,
	x_owning_organization_id  		NUMBER,
	x_vendor_business_type	  		VARCHAR2,
	x_asl_status_id		  		NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
	x_manufacturer_id	  		NUMBER,
	x_vendor_id		  		NUMBER,
	x_item_id		  		NUMBER,
	x_category_id		  		NUMBER,
	x_vendor_site_id	  		NUMBER,
	x_primary_vendor_item  	  		VARCHAR2,
	x_manufacturer_asl_id     		NUMBER,
	x_comments				VARCHAR2,
	x_review_by_date			DATE,
	x_attribute_category	  		VARCHAR2,
	x_attribute1		  		VARCHAR2,
	x_attribute2		  		VARCHAR2,
	x_attribute3		  		VARCHAR2,
	x_attribute4		  		VARCHAR2,
	x_attribute5		  		VARCHAR2,
	x_attribute6		  		VARCHAR2,
	x_attribute7		  		VARCHAR2,
	x_attribute8		  		VARCHAR2,
	x_attribute9		  		VARCHAR2,
	x_attribute10		  		VARCHAR2,
	x_attribute11		  		VARCHAR2,
	x_attribute12		  		VARCHAR2,
	x_attribute13		  		VARCHAR2,
	x_attribute14		  		VARCHAR2,
	x_attribute15		  		VARCHAR2,
	x_last_update_login	  		NUMBER,
        x_disable_flag                          VARCHAR2) is

  cursor row_id is 	SELECT rowid
			FROM   PO_APPROVED_SUPPLIER_LIST
    		   	WHERE  x_asl_id = asl_id;

  x_record_unique	BOOLEAN;

  -- <INBOUND LOGISTICS FPJ START>
  l_api_version      CONSTANT NUMBER := 1.0;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         FND_NEW_MESSAGES.message_text%TYPE;
  l_msg_buf          VARCHAR2(2000);
  l_api_name         CONSTANT VARCHAR2(40) := 'insert_row';
  l_progress         VARCHAR2(3) := '001';
  -- <INBOUND LOGISTICS FPJ END>

begin

  -- Check that the record is unique (i.e., no other
  -- record contains the same supplier/manufactuerer, using_org
  -- and item/commodity).

  x_record_unique := po_asl_sv.check_record_unique(
			  x_manufacturer_id,
			  x_vendor_id,
			  x_vendor_site_id,
			  x_item_id,
			  x_category_id,
			  x_using_organization_id);

  if not x_record_unique then

	fnd_message.set_name('FND','PO_ASL_SUPPLIER_ITEM_DUP');
        app_exception.raise_exception;

  end if;

  if (x_asl_id is null) then

    SELECT po_approved_supplier_list_s.nextval
    INTO   x_asl_id
    FROM   sys.dual;

  end if;

    INSERT INTO PO_APPROVED_SUPPLIER_LIST(
	asl_id		  	,
	using_organization_id   ,
	owning_organization_id  ,
	vendor_business_type	,
	asl_status_id		,
	last_update_date	,
	last_updated_by	  	,
	creation_date		,
	created_by		,
	manufacturer_id	  	,
	vendor_id		,
	item_id		  	,
	category_id		,
	vendor_site_id	  	,
	primary_vendor_item  	,
	manufacturer_asl_id     ,
	comments		,
	review_by_date		,
	attribute_category	,
	attribute1		,
	attribute2		,
	attribute3		,
	attribute4		,
	attribute5		,
	attribute6		,
	attribute7		,
	attribute8		,
	attribute9		,
	attribute10		,
	attribute11		,
	attribute12		,
	attribute13		,
	attribute14		,
	attribute15		,
	last_update_login	,
        disable_flag
     )  VALUES 			(
	x_asl_id		  ,
	x_using_organization_id   ,
	x_owning_organization_id  ,
	x_vendor_business_type	  ,
	x_asl_status_id		  ,
	x_last_update_date	  ,
	x_last_updated_by	  ,
	x_creation_date		  ,
	x_created_by		  ,
	x_manufacturer_id	  ,
	x_vendor_id		  ,
	x_item_id		  ,
	x_category_id		  ,
	x_vendor_site_id	  ,
	x_primary_vendor_item  	  ,
	x_manufacturer_asl_id     ,
	x_comments		  ,
	x_review_by_date	  ,
	x_attribute_category	  ,
	x_attribute1		  ,
	x_attribute2		  ,
	x_attribute3		  ,
	x_attribute4		  ,
	x_attribute5		  ,
	x_attribute6		  ,
	x_attribute7		  ,
	x_attribute8		  ,
	x_attribute9		  ,
	x_attribute10		  ,
	x_attribute11		  ,
	x_attribute12		  ,
	x_attribute13		  ,
	x_attribute14		  ,
	x_attribute15		  ,
	x_last_update_login	  ,
        x_disable_flag
	);

  OPEN row_id;
  FETCH row_id INTO x_row_id;
  if (row_id%notfound) then
    CLOSE row_id;
    raise no_data_found;
  end if;
  CLOSE row_id;

  -- <INBOUND LOGISTICS FPJ START>
  l_progress := '020';
  l_return_status  := FND_API.G_RET_STS_SUCCESS;
  IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string( LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                      MODULE    => c_log_head || '.'||l_api_name||'.' || l_progress,
                      MESSAGE   => 'Call PO_BUSINESSEVENT_PVT.raise_event'
                    );
      END IF;
  END IF;

  PO_BUSINESSEVENT_PVT.raise_event
  (
      p_api_version      =>    l_api_version,
      x_return_status    =>    l_return_status,
      x_msg_count        =>    l_msg_count,
      x_msg_data         =>    l_msg_data,
      p_event_name       =>    'oracle.apps.po.event.create_asl',
      p_entity_name      =>    'ASL',
      p_entity_id        =>    x_asl_id
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (g_fnd_debug = 'Y') THEN
          l_msg_buf := NULL;
          l_msg_buf := FND_MSG_PUB.Get( p_msg_index => 1,
                                        p_encoded   => 'F');
          l_msg_buf := SUBSTR('ASL' || x_asl_id || 'errors out at' || l_progress || l_msg_buf, 1, 2000);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
            FND_LOG.string( LOG_LEVEL => FND_LOG.level_unexpected,
                          MODULE    => c_log_head || '.'||l_api_name||'.error_exception',
                          MESSAGE   => l_msg_buf
                        );
          END IF;
      END IF;
  ELSE
      IF (g_fnd_debug = 'Y') THEN
          l_msg_buf := NULL;
          l_msg_buf := SUBSTR('ASL' || x_asl_id||'raised business event successfully', 1, 2000);
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string( LOG_LEVEL => FND_LOG.level_statement,
                          MODULE    => c_log_head || '.'||l_api_name,
                          MESSAGE   => l_msg_buf
                        );
          END IF;
      END IF;
  END IF;  -- IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)

EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string( LOG_LEVEL => FND_LOG.LEVEL_EXCEPTION,
                            MODULE    => c_log_head || '.'||l_api_name,
                            MESSAGE   => SQLERRM(SQLCODE)
                          );
            END IF;
        END IF;

        APP_EXCEPTION.raise_exception;  -- <ASL ERECORD FPJ>
-- <INBOUND LOGISTICS FPJ END>

end insert_row;

END PO_ASL_THS;

/
