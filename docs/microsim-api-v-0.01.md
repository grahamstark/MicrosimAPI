# A Simple API For Controlling Microsimulation Models

v0.0.1 September 2025

graham.stark@northumbria.ac.uk

## Objective

control any .. canonical is Tax Benefit model

### In Scope

control and display a single run of an arbitrary model
in any language
discover the structure of the model at run-time or in advance

### Out-of-Scope

Authentication
Long-term users - previous results, etc.

### Tech

* REST API
* JSON
* Markdown

### Example API

```

api.virtual-worlds.scot

/[model]/session/start
/[model]/session/destroy

/[model]/params/list-available
/[model]/params/initialise/[defaults]
/[model]/params/set
/[model]/params/validate
/[model]/params/describe
/[model]/params/subsys
/[model]/params/helppage
/[model]/params/labels

or /params/[sysno]/[subsys]/[subsys]/set ... for individual pages

/[model]/settings/set
/[model]/settings/validate
...

/[model]/run/submit
/[model]/run/status
/[model]/run/abort

/[model]/output/items
/[model]/output/phunpak
/[model]/output/labels
/[model]/output/fetch/item


```

### Single vs Multishot 

## Structure of a Model

### Parameters vs Settings

### Outputs 

## Running 

### State Queries

## A simple worked example