-- ============================================
-- CENTRALIZED ENERGY DATA MANAGEMENT SYSTEM
-- University of Ghana | MSBA 611
-- Database Creation Script
-- ============================================

CREATE DATABASE GhanaEnergyDB;
USE GhanaEnergyDB;

-- ============================================
-- TABLE 1: REGION
-- Parent table — no dependencies
-- ============================================
CREATE TABLE Region (
    RegionID      INT           NOT NULL AUTO_INCREMENT,
    RegionName    VARCHAR(100)  NOT NULL UNIQUE,
    RegionManager VARCHAR(100)  NOT NULL,
    PRIMARY KEY (RegionID)
);

-- ============================================
-- TABLE 2: PLANT
-- Depends on Region
-- ============================================
CREATE TABLE Plant (
    PlantID         INT           NOT NULL AUTO_INCREMENT,
    PlantName       VARCHAR(100)  NOT NULL UNIQUE,
    PlantLocation   VARCHAR(100)  NOT NULL,
    PlantCapacityMW DECIMAL(10,2) NOT NULL,
    RegionID        INT           NOT NULL,
    PRIMARY KEY (PlantID),
    CONSTRAINT chk_PlantCapacity CHECK (PlantCapacityMW > 0),
    CONSTRAINT fk_Plant_Region FOREIGN KEY (RegionID)
        REFERENCES Region(RegionID)
);

-- ============================================
-- TABLE 3: SUBSTATION
-- Depends on Region
-- ============================================
CREATE TABLE Substation (
    SubstationID       INT           NOT NULL AUTO_INCREMENT,
    SubstationName     VARCHAR(50)   NOT NULL UNIQUE,
    SubstationCapacity DECIMAL(10,2) NOT NULL,
    RegionID           INT           NOT NULL,
    PRIMARY KEY (SubstationID),
    CONSTRAINT chk_SubCapacity CHECK (SubstationCapacity > 0),
    CONSTRAINT fk_Substation_Region FOREIGN KEY (RegionID)
        REFERENCES Region(RegionID)
);

-- ============================================
-- TABLE 4: GENERATION
-- Depends on Plant and Substation
-- ============================================
CREATE TABLE Generation (
    GenerationID       INT           NOT NULL AUTO_INCREMENT,
    PlantID            INT           NOT NULL,
    GenerationDate     DATE          NOT NULL,
    EnergyGeneratedMWh DECIMAL(12,2) NOT NULL,
    SubstationID       INT           NOT NULL,
    PRIMARY KEY (GenerationID),
    CONSTRAINT chk_EnergyGenerated CHECK (EnergyGeneratedMWh >= 0),
    CONSTRAINT fk_Generation_Plant FOREIGN KEY (PlantID)
        REFERENCES Plant(PlantID),
    CONSTRAINT fk_Generation_Substation FOREIGN KEY (SubstationID)
        REFERENCES Substation(SubstationID)
);

-- ============================================
-- TABLE 5: CUSTOMER
-- No dependencies
-- ============================================
CREATE TABLE Customer (
    CustomerID     VARCHAR(20) NOT NULL,
    CustomerType   VARCHAR(20) NOT NULL,
    CustomerRegion VARCHAR(100) NOT NULL,
    PRIMARY KEY (CustomerID),
    CONSTRAINT chk_CustomerType CHECK (
        CustomerType IN ('Residential', 'Commercial', 'Industrial'))
);

-- ============================================
-- TABLE 6: TARIFF
-- No dependencies
-- ============================================
CREATE TABLE Tariff (
    TariffID     INT           NOT NULL AUTO_INCREMENT,
    CustomerType VARCHAR(20)   NOT NULL UNIQUE,
    TariffRate   DECIMAL(10,6) NOT NULL,
    PRIMARY KEY (TariffID),
    CONSTRAINT chk_TariffCustomerType CHECK (
        CustomerType IN ('Residential', 'Commercial', 'Industrial')),
    CONSTRAINT chk_TariffRate CHECK (TariffRate > 0)
);

-- ============================================
-- TABLE 7: BILLING
-- Depends on Customer and Tariff
-- ============================================
CREATE TABLE Billing (
    BillingID         INT           NOT NULL AUTO_INCREMENT,
    CustomerID        VARCHAR(20)   NOT NULL,
    TariffID          INT           NOT NULL,
    EnergyConsumedMWh DECIMAL(12,2) NOT NULL,
    BillingAmount     DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (BillingID),
    CONSTRAINT chk_EnergyConsumed CHECK (EnergyConsumedMWh >= 0),
    CONSTRAINT chk_BillingAmount CHECK (BillingAmount >= 0),
    CONSTRAINT fk_Billing_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),
    CONSTRAINT fk_Billing_Tariff FOREIGN KEY (TariffID)
        REFERENCES Tariff(TariffID)
);

-- ============================================
-- TABLE 8: PAYMENT
-- Depends on Billing
-- ============================================
CREATE TABLE Payment (
    PaymentID     VARCHAR(20) NOT NULL,
    BillingID     INT         NOT NULL UNIQUE,
    PaymentDate   DATE        NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    PRIMARY KEY (PaymentID),
    CONSTRAINT chk_PaymentMethod CHECK (
        PaymentMethod IN ('Cash', 'Bank Transfer', 'Mobile Money')),
    CONSTRAINT fk_Payment_Billing FOREIGN KEY (BillingID)
        REFERENCES Billing(BillingID)
);

-- ============================================
-- TABLE 9: OUTAGE
-- Depends on Substation
-- ============================================
CREATE TABLE Outage (
    OutageID         VARCHAR(20)  NOT NULL,
    SubstationID     INT          NOT NULL,
    OutageDurationHrs DECIMAL(6,2) NOT NULL,
    OutageCause      VARCHAR(50)  NOT NULL,
    PRIMARY KEY (OutageID),
    CONSTRAINT chk_OutageDuration CHECK (OutageDurationHrs >= 0),
    CONSTRAINT chk_OutageCause CHECK (
        OutageCause IN ('Fault', 'Overload', 'Maintenance')),
    CONSTRAINT fk_Outage_Substation FOREIGN KEY (SubstationID)
        REFERENCES Substation(SubstationID)
);

-- ============================================
-- TABLE 10: MAINTENANCE
-- Depends on Outage
-- ============================================
CREATE TABLE Maintenance (
    MaintenanceID   VARCHAR(20)   NOT NULL,
    OutageID        VARCHAR(20)   NOT NULL,
    MaintenanceType VARCHAR(50)   NOT NULL,
    MaintenanceCost DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (MaintenanceID),
    CONSTRAINT chk_MaintenanceType CHECK (
        MaintenanceType IN ('Inspection', 'Routine', 'Emergency')),
    CONSTRAINT chk_MaintenanceCost CHECK (MaintenanceCost >= 0),
    CONSTRAINT fk_Maintenance_Outage FOREIGN KEY (OutageID)
        REFERENCES Outage(OutageID)
);