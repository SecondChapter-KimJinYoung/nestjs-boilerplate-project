import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api', {
    exclude: ['health'], // /health는 prefix 없이 접근
  });
  await app.listen(3001);
}
bootstrap();
