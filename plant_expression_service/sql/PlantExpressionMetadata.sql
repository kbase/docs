CREATE TABLE IF NOT EXISTS experiment (
 eid MEDIUMINT NOT NULL PRIMARY KEY,
 eid_extern varchar(15) NOT NULL UNIQUE KEY,
 description text NOT NULL
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS smpl_annot_lookup (
 annot_id MEDIUMINT NOT NULL PRIMARY KEY,
 annotation text NOT NULL
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS sample (
 sid MEDIUMINT NOT NULL PRIMARY KEY,
 sid_extern varchar(15) NOT NULL,
 replicate text NOT NULL,
 annot_id MEDIUMINT NOT NULL REFERENCES smpl_annot_lookup (annot_id)
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS po (
 poid MEDIUMINT NOT NULL PRIMARY KEY,
 poid_extern varchar(15) NOT NULL,
 po_anatomy text NOT NULL,
 parent_poid MEDIUMINT
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS eo (
 eoid MEDIUMINT NOT NULL PRIMARY KEY,
 eoid_extern varchar(15) NOT NULL,
 eo_desc text NOT NULL
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS smpl_po (
 sid MEDIUMINT NOT NULL REFERENCES sample(sid),
 poid MEDIUMINT NOT NULL REFERENCES po(poid),
 PRIMARY KEY (sid,poid)
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS smpl_eo (
 sid MEDIUMINT NOT NULL REFERENCES sample(sid),
 eoid MEDIUMINT NOT NULL REFERENCES eo(eoid),
 PRIMARY KEY (sid,eoid)
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS exprmnt_smpl (
 sid MEDIUMINT NOT NULL REFERENCES sample (sid),
 eid MEDIUMINT NOT NULL REFERENCES experiment (eid),
 PRIMARY KEY (sid, eid)
) ENGINE=MyISAM;

ALTER TABLE sample ADD COLUMN species VARCHAR(30);
UPDATE sample SET species="Arabidopsis thaliana" WHERE sid>=1 and sid<=1289;
UPDATE sample SET species="Populus trichocarpa" where sid>=1290 and sid<=1594;
commit;

