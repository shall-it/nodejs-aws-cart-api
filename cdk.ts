#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import * as apigateway from "aws-cdk-lib/aws-apigateway";
import * as lambda from 'aws-cdk-lib/aws-lambda';
import { NodejsFunction, NodejsFunctionProps } from 'aws-cdk-lib/aws-lambda-nodejs';
// import dotenv from 'dotenv';
import * as dotenv from 'dotenv';

dotenv.config();

const app = new cdk.App();

const cartApiAWSRegion = process.env.CART_API_AWS_REGION!
if (!cartApiAWSRegion) {
  throw new Error('Variable CART_API_AWS_REGION must be set into .env file');
}

console.log(`CDK region for deploy: ${cartApiAWSRegion}`);

const stack = new cdk.Stack(app, 'CartApiServiceStack', {
  env: { region: cartApiAWSRegion }
});

const sharedLambdaProps: Partial<NodejsFunctionProps> = {
  runtime: lambda.Runtime.NODEJS_20_X,
  environment: {
    IMPORT_AWS_REGION: cartApiAWSRegion,
  }
};

const CartApi = new NodejsFunction(stack, 'CartApiLambda', {
  ...sharedLambdaProps,
  functionName: 'cartApiService',
  entry: 'dist/main.js',
  handler: 'main.handler'
});

const api = new apigateway.RestApi(stack, 'ImportApiRest', {
  defaultCorsPreflightOptions: {
    allowOrigins: apigateway.Cors.ALL_ORIGINS,
    allowMethods: apigateway.Cors.ALL_METHODS,
    allowHeaders: ['*']
  }
});

const integration = new apigateway.LambdaIntegration(CartApi);

api.root.addProxy({
  defaultIntegration: integration,
});